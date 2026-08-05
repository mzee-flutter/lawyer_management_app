# repositories/certified_copy_repository.py
#
# Owns the certified_copies table entirely.
# Follows your HearingRepository pattern exactly:
#   - All @staticmethod methods
#   - Pure data access — zero business logic
#   - Returns ORM objects, never Pydantic shapes
#
# Also contains the CaseRepository additions needed
# for the bench roster (paste into your CaseRepository).

from uuid import UUID
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import and_

# Adjust these imports to match your project structure
from app.models.certified_copy_model     import CertifiedCopy
from app.models.case_model import Case, CaseStage,Hearing





class CertifiedCopyRepository:

    @staticmethod
    def create(db: Session, copy_data: dict) -> CertifiedCopy:
        """Create a new certified copy application."""
        copy = CertifiedCopy(**copy_data)
        db.add(copy)
        db.commit()
        db.refresh(copy)
        return copy

    @staticmethod
    def get_by_id(db: Session, copy_id: UUID) -> CertifiedCopy | None:
        return (
            db.query(CertifiedCopy)
            .filter(CertifiedCopy.id == copy_id)
            .first()
        )

    @staticmethod
    def get_all_by_user(
        db: Session,
        user_id: UUID,
        status_filter: str | None = None,   # optional: "applied" | "processing" | "ready"
    ) -> list[CertifiedCopy]:
        """
        Returns all copies for a user, optionally filtered by status.
        Joined with Case so the service can build denormalised responses.
        """
        query = (
            db.query(CertifiedCopy, Case)
            .join(Case, CertifiedCopy.case_id == Case.id)
            .filter(CertifiedCopy.user_id == user_id)
        )
        if status_filter:
            query = query.filter(CertifiedCopy.status == status_filter)

        return (
            query
            .order_by(CertifiedCopy.created_at.desc())
            .all()
        )

    @staticmethod
    def get_all_by_case(
        db: Session,
        case_id: UUID,
        user_id: UUID,
    ) -> list[CertifiedCopy]:
        """Returns all copies for a specific case, scoped to user."""
        return (
            db.query(CertifiedCopy)
            .filter(
                and_(
                    CertifiedCopy.case_id == case_id,
                    CertifiedCopy.user_id == user_id,
                )
            )
            .order_by(CertifiedCopy.created_at.desc())
            .all()
        )

    @staticmethod
    def update(db: Session, copy: CertifiedCopy) -> CertifiedCopy:
        """Commits an already-mutated ORM object. Service applies field changes."""
        copy.updated_at = datetime.now()
        db.commit()
        db.refresh(copy)
        return copy

    @staticmethod
    def delete(db: Session, copy: CertifiedCopy) -> None:
        db.delete(copy)
        db.commit()


