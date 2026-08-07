# services/court_portal_service.py
#
# All business logic for the Court Portal feature.
# Follows your HearingService pattern exactly:
#   1. Guards / validation
#   2. Business logic (state machine, grouping, sorting)
#   3. Delegate to Repository
#   4. Serialize into Pydantic response shapes
#   5. Return — never touches HTTP

from collections import defaultdict
from datetime import datetime, timezone
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.certified_copy_model import CertifiedCopy, CertifiedCopyStatus
from app.repositories.certified_copy_repository import CertifiedCopyRepository
from app.schemas.court_portal_schema import (
    BenchCard,
    BenchRosterResponse,
    CertifiedCopyCreate,
    CertifiedCopyPublic,
    CertifiedCopyUpdate,
    RosterCaseItem,
    VALID_STATUS_TRANSITIONS,
)

# Import your existing CaseRepository
from app.repositories.case_repository import CaseRepository,CaseRepositoryRosterAdditions


class CourtPortalService:

    # ══════════════════════════════════════════════════════════════
    # BENCH ROSTER
    # ══════════════════════════════════════════════════════════════

    @staticmethod
    def get_bench_roster(
        db: Session,
        user_id: UUID,
    ) -> BenchRosterResponse:
        """
        Groups the lawyer's active cases by (court_name, judge_name)
        to produce a bench-by-bench roster view.

        Business logic here:
          - Filter out cases with no court_name (can't appear in a roster)
          - Group by court + judge
          - Sort benches by case count descending (busiest court first)
          - Within each bench, sort cases by next_hearing_at ascending
        """
        raw_records = CaseRepositoryRosterAdditions.get_active_cases_with_stage_and_next_hearing(
            db=db,
            user_id=user_id,
        )

        if not raw_records:
            return BenchRosterResponse(benches=[], total_cases=0)

        # Group by (court_name, judge_name)
        bench_map: dict[tuple[str, str | None], list] = defaultdict(list)
        for case, case_stage, next_hearing_at in raw_records:
            key = (case.court_name, case.judge_name)
            bench_map[key].append((case, case_stage, next_hearing_at))

        # Build BenchCard objects
        bench_cards: list[BenchCard] = []
        for (court_name, judge_name), records in bench_map.items():
            # Sort cases within bench: those with upcoming hearings first
            records.sort(
                key=lambda r: (r[2] is None, r[2] or datetime.max)
            )
            case_items = [
                RosterCaseItem(
                    case_id=str(case.id),
                    case_number=case.case_number,
                    first_party_name=case.first_party_name,
                    opposite_party_name=case.opposite_party_name,
                    case_stage_name=case_stage.name if case_stage else None,
                    next_hearing_at=next_hearing_at,
                )
                for case, case_stage, next_hearing_at in records
            ]
            bench_cards.append(
                BenchCard(
                    court_name=court_name,
                    judge_name=judge_name,
                    case_count=len(case_items),
                    cases=case_items,
                )
            )

        # Sort benches: busiest court first
        bench_cards.sort(key=lambda b: b.case_count, reverse=True)

        return BenchRosterResponse(
            benches=bench_cards,
            total_cases=len(raw_records),
        )

    # ══════════════════════════════════════════════════════════════
    # CERTIFIED COPIES — CRUD
    # ══════════════════════════════════════════════════════════════

    @staticmethod
    def create_copy(
        db: Session,
        payload: CertifiedCopyCreate,
        user_id: UUID,
    ) -> CertifiedCopyPublic:
        """
        Creates a new certified copy application.
        Status starts at 'applied' with applied_at = now.
        """
        # Verify the case exists and belongs to this user
        case = CaseRepository.get_by_id(db, payload.case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        if str(case.user_id) != str(user_id):
            raise HTTPException(status_code=403, detail="Access denied")
        if case.archived_at is not None:
            raise HTTPException(
                status_code=400,
                detail="Cannot add certified copy to an archived case"
            )

        now = datetime.now(timezone.utc)
        copy_data = {
            "case_id":          payload.case_id,
            "user_id":          user_id,
            "reference_number": payload.reference_number.strip(),
            "description":      payload.description,
            "status":           CertifiedCopyStatus.applied,
            "applied_at":       now,
            "created_at":       now,
        }

        copy = CertifiedCopyRepository.create(db, copy_data)
        return _build_public(copy, case)

    @staticmethod
    def get_all_copies(
        db: Session,
        user_id: UUID,
        status_filter: str | None = None,
    ) -> list[CertifiedCopyPublic]:
        """
        Returns all certified copies for the authenticated lawyer,
        with optional status filter.
        """
        if status_filter and status_filter not in ("applied", "processing", "ready"):
            raise HTTPException(status_code=422, detail="Invalid status filter")

        raw_records = CertifiedCopyRepository.get_all_by_user(
            db, user_id, status_filter
        )
        return [_build_public(copy, case) for copy, case in raw_records]

    @staticmethod
    def get_copies_by_case(
        db: Session,
        case_id: UUID,
        user_id: UUID,
    ) -> list[CertifiedCopyPublic]:
        """Returns all copies for a specific case."""
        case = CaseRepository.get_by_id(db, case_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        copies = CertifiedCopyRepository.get_all_by_case(db, case_id, user_id)
        return [_build_public(copy, case) for copy in copies]

    @staticmethod
    def advance_status(
        db: Session,
        copy_id: UUID,
        payload: CertifiedCopyUpdate,
        user_id: UUID,
    ) -> CertifiedCopyPublic:
        """
        Updates a certified copy.

        STATE MACHINE ENFORCEMENT:
          applied → processing → ready
          Backward transitions raise 400.
          Skipping a stage raises 400.

        Also allows correcting reference_number and description.
        """
        copy = CertifiedCopyRepository.get_by_id(db, copy_id)
        if not copy:
            raise HTTPException(status_code=404, detail="Certified copy not found")
        if str(copy.user_id) != str(user_id):
            raise HTTPException(status_code=403, detail="Access denied")

        now = datetime.now(timezone.utc)

        # ── Status transition validation ────────────────────────
        if payload.status is not None:
            current = copy.status.value if hasattr(copy.status, 'value') else copy.status
            new_status = payload.status

            allowed = VALID_STATUS_TRANSITIONS.get(current, set())
            if new_status not in allowed:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Cannot transition from '{current}' to '{new_status}'. "
                        f"Allowed: {allowed or 'none (terminal state)'}"
                    ),
                )

            copy.status = new_status

            # Stamp the timestamp for the new stage
            if new_status == "processing":
                copy.processing_at = now
            elif new_status == "ready":
                copy.ready_at = now

        # ── Field corrections ───────────────────────────────────
        if payload.reference_number is not None:
            copy.reference_number = payload.reference_number.strip()
        if payload.description is not None:
            copy.description = payload.description

        copy = CertifiedCopyRepository.update(db, copy)

        case = CaseRepository.get_by_id(db, copy.case_id, user_id)
        return _build_public(copy, case)

    @staticmethod
    def delete_copy(
        db: Session,
        copy_id: UUID,
        user_id: UUID,
    ) -> CertifiedCopyPublic:
        """
        Deletes a certified copy application.
        Only 'applied' copies can be deleted — once processing begins,
        it's a legal record and should not be removed.
        """
        copy = CertifiedCopyRepository.get_by_id(db, copy_id)
        if not copy:
            raise HTTPException(status_code=404, detail="Certified copy not found")
        if str(copy.user_id) != str(user_id):
            raise HTTPException(status_code=403, detail="Access denied")

        current = copy.status.value if hasattr(copy.status, 'value') else copy.status
        if current != "applied":
            raise HTTPException(
                status_code=400,
                detail="Only 'applied' copies can be deleted. "
                       "In-progress or ready copies are legal records.",
            )

        case = CaseRepository.get_by_id(db, copy.case_id,user_id)
        copy_snapshot = _build_public(copy, case)
        CertifiedCopyRepository.delete(db, copy)
        return copy_snapshot


# ─────────────────────────────────────────────────────────────────
# Private builder — assembles CertifiedCopyPublic from ORM objects
# Kept here (service layer) since it requires business knowledge
# of which fields to denormalise from Case
# ─────────────────────────────────────────────────────────────────
def _build_public(copy: CertifiedCopy, case) -> CertifiedCopyPublic:
    return CertifiedCopyPublic(
        id=copy.id,
        case_id=copy.case_id,
        reference_number=copy.reference_number,
        description=copy.description,
        status=copy.status.value if hasattr(copy.status, 'value') else copy.status,
        applied_at=copy.applied_at,
        processing_at=copy.processing_at,
        ready_at=copy.ready_at,
        created_at=copy.created_at,
        updated_at=copy.updated_at,
        # Denormalised from Case
        case_number=case.case_number,
        first_party_name=case.first_party_name,
        opposite_party_name=case.opposite_party_name,
        court_name=case.court_name,
    )