# repositories/legal_task_repository.py
#
# Owns the legal_tasks table entirely.
# Follows your HearingRepository pattern exactly:
#   - All @staticmethod methods
#   - Pure data access — zero business logic
#   - Returns ORM objects, never Pydantic shapes
#   - Joins with Case table for denormalised responses

from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_

from app.models.legal_task_model import LegalTask
from app.models.case_model import Case


class LegalTaskRepository:

    @staticmethod
    def create(db: Session, task_data: dict) -> LegalTask:
        task = LegalTask(**task_data)
        db.add(task)
        db.commit()
        db.refresh(task)
        return task

    @staticmethod
    def get_by_id(db: Session, task_id: UUID) -> LegalTask | None:
        return (
            db.query(LegalTask)
            .filter(LegalTask.id == task_id)
            .first()
        )

    @staticmethod
    def get_all_by_user(
        db: Session,
        user_id: UUID,
        case_id: UUID | None = None,
        include_completed: bool = True,
    ) -> list[tuple]:   # list[tuple[LegalTask, Case]]
        """
        Fetches all tasks for a user, optionally filtered by case.
        Joined with Case for denormalised fields.
        Returns completed tasks from the last 30 days only —
        older completed tasks are excluded to keep the list clean.
        """
        from datetime import timedelta, timezone
        thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)

        query = (
            db.query(LegalTask, Case)
            .join(Case, LegalTask.case_id == Case.id)
            .filter(LegalTask.user_id == user_id)
        )

        if case_id:
            query = query.filter(LegalTask.case_id == case_id)

        if include_completed:
            # Include open tasks + completed tasks from last 30 days
            query = query.filter(
                or_(
                    LegalTask.is_completed == False,
                    and_(
                        LegalTask.is_completed == True,
                        LegalTask.completed_at >= thirty_days_ago,
                    ),
                )
            )
        else:
            query = query.filter(LegalTask.is_completed == False)

        return (
            query
            .order_by(LegalTask.due_date.asc().nulls_last())
            .all()
        )

    @staticmethod
    def update(db: Session, task: LegalTask) -> LegalTask:
        """Commits an already-mutated ORM object."""
        task.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(task)
        return task

    @staticmethod
    def delete(db: Session, task: LegalTask) -> None:
        db.delete(task)
        db.commit()

    @staticmethod
    def get_auto_task_exists(
        db: Session,
        source_hearing_id: UUID,
    ) -> bool:
        """
        Prevents duplicate auto-tasks for the same hearing.
        Called before creating an auto-generated task from a hearing save.
        """
        return (
            db.query(LegalTask)
            .filter(LegalTask.source_hearing_id == source_hearing_id)
            .filter(LegalTask.is_auto_generated == True)
            .first()
        ) is not None