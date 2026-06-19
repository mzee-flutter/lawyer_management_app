from sqlalchemy.orm import Session
from sqlalchemy import or_, asc, desc
from app.models.case_model import Case, CourtCategory, CaseType, CaseStage, CaseStatus, CaseFile, CaseRelatedClient
from app.schemas.case_schema import CaseCreate, CaseFileCreate, CaseUpdate, CaseRelatedClientCreate, CaseRelatedClientPublic

from datetime import datetime, timezone
from uuid import UUID
import uuid


class CaseRepository:
    # ✅ Create a new case
    @staticmethod
    def create(db: Session, case_in: CaseCreate) -> Case:
        db_case = Case(**case_in.model_dump())
        db.add(db_case)
        db.commit()
        db.refresh(db_case)
        return db_case

    # ✅ Get a case by ID
    @staticmethod
    def get_by_id(db: Session, case_id) -> Case | None:
        return db.query(Case).filter(Case.id == case_id).first()

    # ✅ Search active (non-archived) cases
    @staticmethod
    def search(
        db: Session,
        query: str | None = None,
        skip: int = 0,
        limit: int = 10,
        sort: str | None = None,
    ) -> list[Case]:
        q = db.query(Case).filter(Case.archived_at.is_(None))

        # Filtering by text query (case number, judge name, etc.)
        if query:
            q = q.filter(
                or_(
                    Case.case_number.ilike(f"%{query}%"),
                    Case.court_name.ilike(f"%{query}%"),
                    Case.judge_name.ilike(f"%{query}%"),
                    Case.status.ilike(f"%{query}%"),
                    Case.case_notes.ilike(f"%{query}%"),
                )
            )

        # Sorting
        if sort:
            try:
                field, direction = sort.split(",")
                sort_column = getattr(Case, field)
                q = q.order_by(
                    desc(sort_column) if direction.lower() == "desc" else asc(sort_column)
                )
            except Exception:
                raise ValueError("Invalid sort format. Use field,asc or field,desc")
        else:
            q = q.order_by(desc(Case.created_at))

        # Pagination
        return q.offset(skip).limit(limit).all()

    # ✅ Search archived (soft-deleted) cases
    @staticmethod
    def search_archived(
        db: Session,
        query: str | None = None,
        skip: int = 0,
        limit: int = 10,
        sort: str | None = None
    ) -> list[Case]:
        q = db.query(Case).filter(Case.archived_at.isnot(None))

        if query:
            q = q.filter(
                or_(
                    Case.case_number.ilike(f"%{query}%"),
                    Case.court_name.ilike(f"%{query}%"),
                    Case.judge_name.ilike(f"%{query}%"),
                    Case.status.ilike(f"%{query}%"),
                    Case.case_notes.ilike(f"%{query}%"),
                )
            )

        if sort:
            try:
                field, direction = sort.split(",")
                sort_column = getattr(Case, field)
                q = q.order_by(desc(sort_column) if direction.lower() == "desc" else asc(sort_column))
            except Exception:
                raise ValueError("Invalid sort format. Use field,asc or field,desc")
        else:
            q= q.order_by(desc(Case.created_at))

        return q.offset(skip).limit(limit).all()

    # ✅ Update an existing case
    @staticmethod
    def update(db: Session, case: Case, case_in: CaseUpdate) -> Case:
        for field, value in case_in.model_dump(exclude_unset=True).items():
            setattr(case, field, value)
        case.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(case)
        return case

    # ✅ Soft delete (archive) a case
    @staticmethod
    def archive(db: Session, case: Case) -> Case:
        case.archived_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(case)
        return case

    # ✅ Restore a soft-deleted case
    @staticmethod
    def restore(db: Session, case: Case) -> Case:
        case.archived_at = None
        db.commit()
        db.refresh(case)
        return case

    # ✅ Hard delete (permanent delete)
    @staticmethod
    def delete(db: Session, case: Case) -> None:
        db.delete(case)
        db.commit()
#----------------------------------------------------------#



class CaseRelatedClientRepository:

    # Attach a client to a case
    @staticmethod
    def add_related_client(db: Session, case_id: UUID, data: CaseRelatedClientCreate):
        related_client = CaseRelatedClient(
            id=uuid.uuid4(),
            case_id=case_id,
            client_id=data.client_id,
            role=data.role
        )
        db.add(related_client)
        db.commit()
        db.refresh(related_client)
        return related_client

    # Get all related clients of a case
    @staticmethod
    def get_all_for_case(db: Session, case_id: UUID) -> list[CaseRelatedClient]:
        return db.query(CaseRelatedClient).filter(CaseRelatedClient.case_id == case_id).all()

    # Get one related client
    @staticmethod
    def get_by_id(db: Session, related_client_id: UUID):
        return db.query(CaseRelatedClient).filter(CaseRelatedClient.id == related_client_id).first()

    # Update related client's role
    @staticmethod
    def update(db: Session, related_client: CaseRelatedClient, role: str | None):
        related_client.role = role
        db.commit()
        db.refresh(related_client)
        return related_client

    # Remove a related client entry (does NOT delete client)
    @staticmethod
    def delete(db: Session, related_client: CaseRelatedClient):
        db.delete(related_client)
        db.commit()


#---------------------------------------------------#

class CourtCategoryRepository:

    @staticmethod
    def get_all(db: Session) -> list[CourtCategory]:
        """Return all main court categories with their subcategories."""
        return db.query(CourtCategory).filter(CourtCategory.parent_id.is_(None)).all()

    @staticmethod
    def get_by_id(db: Session, category_id) -> CourtCategory | None:
        """Return a single court category by ID."""
        return db.query(CourtCategory).filter(CourtCategory.id == category_id).first()

    @staticmethod
    def get_subcategories(db: Session, parent_id) -> list[CourtCategory]:
        """Return subcategories for a specific parent category."""
        return db.query(CourtCategory).filter(CourtCategory.parent_id == parent_id).all()
    


#---------------------------------------------------#



class CaseTypeRepository:

    @staticmethod
    def get_all(db: Session, sort: str | None = None) -> list[CaseType]:
        """Return all case types."""
        q = db.query(CaseType)
        if sort:
            try:
                field, direction = sort.split(",")
                sort_column = getattr(CaseType, field)
                q = q.order_by(
                    desc(sort_column) if direction.lower() == "desc" else asc(sort_column)
                )
            except Exception:
                raise ValueError("Invalid sort format. Use field,asc or field,desc")
        return q.all()

    @staticmethod
    def get_by_id(db: Session, case_type_id) -> CaseType | None:
        """Return a single case type by ID."""
        return db.query(CaseType).filter(CaseType.id == case_type_id).first()



#---------------------------------------------------#





class CaseStageRepository:

    @staticmethod
    def get_all(db: Session, sort: str | None = None) -> list[CaseStage]:
        """Return all case stages."""
        q = db.query(CaseStage)
        if sort:
            try:
                field, direction = sort.split(",")
                sort_column = getattr(CaseStage, field)
                q = q.order_by(
                    desc(sort_column) if direction.lower() == "desc" else asc(sort_column)
                )
            except Exception:
                raise ValueError("Invalid sort format. Use field,asc or field,desc")
        return q.all()

    @staticmethod
    def get_by_id(db: Session, stage_id) -> CaseStage | None:
        """Return a single case stage by ID."""
        return db.query(CaseStage).filter(CaseStage.id == stage_id).first()




#---------------------------------------------------#


class CaseStatusRepository:

    @staticmethod
    def get_all(db: Session, sort: str | None = None) -> list[CaseStatus]:
        """Return all case statuses."""
        q = db.query(CaseStatus)
        if sort:
            try:
                field, direction = sort.split(",")
                sort_column = getattr(CaseStatus, field)
                q = q.order_by(
                    desc(sort_column) if direction.lower() == "desc" else asc(sort_column)
                )
            except Exception:
                raise ValueError("Invalid sort format. Use field,asc or field,desc")
        return q.all()

    @staticmethod
    def get_by_id(db: Session, status_id) -> CaseStatus | None:
        """Return a single case status by ID."""
        return db.query(CaseStatus).filter(CaseStatus.id == status_id).first()
    

#---------------------------------------------------#


class CaseFileRepository:

    @staticmethod
    def create(db: Session, file_data: dict) -> CaseFile:
        db_file = CaseFile(
            id=uuid.uuid4(),
            case_id=file_data["case_id"],
            filename=file_data["filename"],
            file_url=file_data["file_url"],
            uploaded_at=datetime.now(timezone.utc),
        )
        db.add(db_file)
        db.commit()
        db.refresh(db_file)
        return db_file

    @staticmethod
    def get_by_id(db: Session, file_id: UUID) -> CaseFile | None:
        return db.query(CaseFile).filter(CaseFile.id == file_id).first()

    @staticmethod
    def get_all_by_case(db: Session, case_id: UUID) -> list[CaseFile]:
        return db.query(CaseFile).filter(CaseFile.case_id == case_id).all()

    @staticmethod
    def delete(db: Session, file: CaseFile):
        db.delete(file)
        db.commit()