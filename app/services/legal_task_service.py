# services/legal_task_service.py
#
# All business logic for the Legal Task Board.
# Follows your HearingService pattern exactly:
#   1. Guards / validation
#   2. Business logic (bucket computation, priority sorting)
#   3. Delegate to Repository
#   4. Serialize into Pydantic response shapes
#   5. Return — never touches HTTP

from datetime import datetime, timedelta, timezone
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.legal_task_model import LegalTask, TaskPriority
from app.repositories.legal_task_repository import LegalTaskRepository
from app.repositories.case_repository import CaseRepository
from app.schemas.legal_task_schema import (
    LegalTaskCreate,
    LegalTaskPublic,
    LegalTaskUpdate,
    TaskBucketResponse,
    ALLOWED_PRIORITIES,
    PRIORITY_ORDER,
)


class LegalTaskService:

    # ══════════════════════════════════════════════════════════════
    # CREATE
    # ══════════════════════════════════════════════════════════════

    @staticmethod
    def create_task(
        db: Session,
        payload: LegalTaskCreate,
        user_id: UUID,
    ) -> LegalTaskPublic:
        """
        Creates a new task linked to a case.

        Auto-generated tasks (from hearing save hook):
          - is_auto_generated = True
          - source_hearing_id is set
          - Duplicate guard: if a task already exists for this hearing, skip
        """
        # ── Validate case ownership ──────────────────────────────
        case = CaseRepository.get_by_id(db, payload.case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        if str(case.user_id) != str(user_id):
            raise HTTPException(status_code=403, detail="Access denied")
        if case.archived_at is not None:
            raise HTTPException(
                status_code=400,
                detail="Cannot add task to an archived case",
            )

        # ── Validate priority ────────────────────────────────────
        if payload.priority not in ALLOWED_PRIORITIES:
            raise HTTPException(
                status_code=422,
                detail=f"Priority must be one of: {ALLOWED_PRIORITIES}",
            )

        # ── Duplicate guard for auto-generated tasks ─────────────
        if payload.is_auto_generated and payload.source_hearing_id:
            already_exists = LegalTaskRepository.get_auto_task_exists(
                db, payload.source_hearing_id
            )
            if already_exists:
                raise HTTPException(
                    status_code=409,
                    detail="Auto-task for this hearing already exists",
                )

        now = datetime.now(timezone.utc)
        task_data = {
            "case_id":           payload.case_id,
            "user_id":           user_id,
            "task_title":        payload.task_title.strip(),
            "notes":             payload.notes,
            "priority":          TaskPriority(payload.priority),
            "due_date":          payload.due_date,
            "is_auto_generated": payload.is_auto_generated,
            "source_hearing_id": payload.source_hearing_id,
            "is_completed":      False,
            "created_at":        now,
        }

        task = LegalTaskRepository.create(db, task_data)
        return _build_public(task, case)

    # ══════════════════════════════════════════════════════════════
    # READ — bucketed board view
    # ══════════════════════════════════════════════════════════════

    @staticmethod
    def get_task_board(
        db: Session,
        user_id: UUID,
        utc_offset_hours: int,
        case_id: UUID | None = None,
    ) -> TaskBucketResponse:
        """
        Returns tasks bucketed into:
          overdue | this_week | upcoming | no_date | completed

        Buckets are computed using the lawyer's local timezone so that
        "this week" means this week in Pakistan Standard Time, not UTC.

        Within each bucket: sorted by priority (high first), then due_date.
        """
        # ── Compute local "today" boundaries ────────────────────
        tz_offset   = timedelta(hours=utc_offset_hours)
        now_local   = datetime.now(timezone.utc) + tz_offset
        today_start = datetime(
            now_local.year, now_local.month, now_local.day,
            0, 0, 0, tzinfo=timezone.utc
        ) - tz_offset
        week_end    = today_start + timedelta(days=7)

        raw_records = LegalTaskRepository.get_all_by_user(
            db=db,
            user_id=user_id,
            case_id=case_id,
            include_completed=True,
        )

        # ── Bucket tasks ─────────────────────────────────────────
        overdue:   list[LegalTaskPublic] = []
        this_week: list[LegalTaskPublic] = []
        upcoming:  list[LegalTaskPublic] = []
        no_date:   list[LegalTaskPublic] = []
        completed: list[LegalTaskPublic] = []

        for task, case in raw_records:
            public = _build_public(task, case)

            if task.is_completed:
                completed.append(public)
                continue

            if task.due_date is None:
                no_date.append(public)
                continue

            # Normalise to UTC-aware for comparison
            due = task.due_date
            if due.tzinfo is None:
                due = due.replace(tzinfo=timezone.utc)

            if due < today_start:
                overdue.append(public)
            elif due < week_end:
                this_week.append(public)
            else:
                upcoming.append(public)

        # ── Sort each bucket: priority first, then due_date ──────
        def sort_key(t: LegalTaskPublic):
            return (
                PRIORITY_ORDER.get(t.priority, 99),
                t.due_date or datetime.max.replace(tzinfo=timezone.utc),
            )

        overdue.sort(key=sort_key)
        this_week.sort(key=sort_key)
        upcoming.sort(key=sort_key)
        no_date.sort(key=lambda t: PRIORITY_ORDER.get(t.priority, 99))
        # Completed sorted newest-first
        completed.sort(
            key=lambda t: t.completed_at or t.created_at, reverse=True
        )

        total_open = len(overdue) + len(this_week) + len(upcoming) + len(no_date)

        return TaskBucketResponse(
            overdue=overdue,
            this_week=this_week,
            upcoming=upcoming,
            no_date=no_date,
            completed=completed,
            overdue_count=len(overdue),
            this_week_count=len(this_week),
            total_open=total_open,
        )

    # ══════════════════════════════════════════════════════════════
    # UPDATE — edit fields OR mark complete
    # ══════════════════════════════════════════════════════════════

    @staticmethod
    def update_task(
        db: Session,
        task_id: UUID,
        payload: LegalTaskUpdate,
        user_id: UUID,
    ) -> LegalTaskPublic:
        """
        Updates task fields.

        Completion logic:
          - Setting is_completed=True  → stamps completed_at = now
          - Setting is_completed=False → clears completed_at (un-complete)
        """
        task = LegalTaskRepository.get_by_id(db, task_id)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")
        if str(task.user_id) != str(user_id):
            raise HTTPException(status_code=403, detail="Access denied")

        now = datetime.now(timezone.utc)
        update_data = payload.model_dump(exclude_unset=True)

        for field, value in update_data.items():
            if field == "priority" and value is not None:
                if value not in ALLOWED_PRIORITIES:
                    raise HTTPException(
                        status_code=422,
                        detail=f"Priority must be one of: {ALLOWED_PRIORITIES}",
                    )
                setattr(task, field, TaskPriority(value))
            else:
                setattr(task, field, value)

        # Completion timestamp logic
        if "is_completed" in update_data:
            if update_data["is_completed"] is True:
                task.completed_at = now
            else:
                task.completed_at = None   # un-completing clears the stamp

        task = LegalTaskRepository.update(db, task)
        case = CaseRepository.get_by_id(db, task.case_id, user_id)
        return _build_public(task, case)

    # ══════════════════════════════════════════════════════════════
    # DELETE
    # ══════════════════════════════════════════════════════════════

    @staticmethod
    def delete_task(
        db: Session,
        task_id: UUID,
        user_id: UUID,
    ) -> LegalTaskPublic:
        task = LegalTaskRepository.get_by_id(db, task_id)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")
        if str(task.user_id) != str(user_id):
            raise HTTPException(status_code=403, detail="Access denied")

        case = CaseRepository.get_by_id(db, task.case_id, user_id)
        snapshot = _build_public(task, case)
        LegalTaskRepository.delete(db, task)
        return snapshot


# ─────────────────────────────────────────────────────────────────
# Private builder — assembles LegalTaskPublic from ORM objects
# ─────────────────────────────────────────────────────────────────
def _build_public(task: LegalTask, case) -> LegalTaskPublic:
    return LegalTaskPublic(
        id=task.id,
        case_id=task.case_id,
        task_title=task.task_title,
        notes=task.notes,
        priority=task.priority.value if hasattr(task.priority, 'value') else task.priority,
        due_date=task.due_date,
        is_completed=task.is_completed,
        completed_at=task.completed_at,
        is_auto_generated=task.is_auto_generated,
        source_hearing_id=task.source_hearing_id,
        created_at=task.created_at,
        updated_at=task.updated_at,
        # Denormalised from Case
        case_number=case.case_number,
        first_party_name=case.first_party_name,
        opposite_party_name=case.opposite_party_name,
        court_name=case.court_name,
    )