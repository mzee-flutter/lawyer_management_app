from sqlalchemy.orm import Session
import os
from fastapi import HTTPException, status
import uuid
from uuid import UUID
from fastapi import UploadFile
from app.repositories.case_repository import (
    CaseRepository,
    CourtCategoryRepository,
    CaseTypeRepository,
    CaseStageRepository,
    CaseStatusRepository,
    CaseFileRepository,
)
from app.schemas.case_schema import (
    CaseCreate,
    CaseUpdate,
    CaseFileCreate,
    CaseFilePublic,
    CasePublic,
    CourtCategoryPublic,
    CaseTypePublic,
    CaseStagePublic,
    CaseStatusPublic,
)
from datetime import datetime


# ---------------------------------------------------
# Case Service
# ---------------------------------------------------

class CaseService:

    # ✅ Create a new case
    @staticmethod
    def create_case(db: Session, case_in: CaseCreate) -> CasePublic:
        case = CaseRepository.create(db, case_in)
        return CasePublic.model_validate(case)

    # ✅ Get a case by ID
    @staticmethod
    def get_case(db: Session, case_id) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        return CasePublic.model_validate(case)

    # ✅ Search active cases
    @staticmethod
    def search_cases(
        db: Session,
        q: str | None = None,
        page: int = 1,
        size: int = 10,
        sort: str | None = None,
    ) -> list[CasePublic]:
        skip = (page - 1) * size
        cases = CaseRepository.search(db, query=q, skip=skip, limit=size, sort=sort)
        return [CasePublic.model_validate(c) for c in cases]

    # ✅ Search archived cases
    @staticmethod
    def search_archived_cases(
        db: Session,
        q: str | None = None,
        page: int = 1,
        size: int = 10,
        sort: str | None = None,
    ) -> list[CasePublic]:
        skip = (page - 1) * size
        cases = CaseRepository.search_archived(db, query=q, skip=skip, limit=size, sort=sort)
        return [CasePublic.model_validate(c) for c in cases]

    # ✅ Update case
    @staticmethod
    def update_case(db: Session, case_id, case_in: CaseUpdate) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        updated = CaseRepository.update(db, case, case_in)
        return CasePublic.model_validate(updated)

    # ✅ Archive case
    @staticmethod
    def archive_case(db: Session, case_id) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        archived = CaseRepository.archive(db, case)
        return CasePublic.model_validate(archived)

    # ✅ Restore case
    @staticmethod
    def restore_case(db: Session, case_id) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        if case.archived_at is None:
            raise HTTPException(status_code=400, detail="Case is not archived")
        restored = CaseRepository.restore(db, case)
        return CasePublic.model_validate(restored)

    # ✅ Delete case permanently
    @staticmethod
    def delete_case_permanently(db: Session, case_id) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        case_copy = CasePublic.model_validate(case)
        CaseRepository.delete(db, case)
        return case_copy


# ---------------------------------------------------
# Court Category Service
# ---------------------------------------------------

class CourtCategoryService:

    @staticmethod
    def get_all_categories(db: Session) -> list[CourtCategoryPublic]:
        categories = CourtCategoryRepository.get_all(db)
        return [CourtCategoryPublic.model_validate(c) for c in categories]

    @staticmethod
    def get_category_by_id(db: Session, category_id) -> CourtCategoryPublic:
        category = CourtCategoryRepository.get_by_id(db, category_id)
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        return CourtCategoryPublic.model_validate(category)

    @staticmethod
    def get_subcategories(db: Session, parent_id) -> list[CourtCategoryPublic]:
        subcategories = CourtCategoryRepository.get_subcategories(db, parent_id)
        return [CourtCategoryPublic.model_validate(s) for s in subcategories]


# ---------------------------------------------------
# Case Type Service
# ---------------------------------------------------

class CaseTypeService:

    @staticmethod
    def get_all_case_types(db: Session, sort: str | None = None) -> list[CaseTypePublic]:
        types = CaseTypeRepository.get_all(db, sort)
        return [CaseTypePublic.model_validate(t) for t in types]

    @staticmethod
    def get_case_type_by_id(db: Session, case_type_id) -> CaseTypePublic:
        case_type = CaseTypeRepository.get_by_id(db, case_type_id)
        if not case_type:
            raise HTTPException(status_code=404, detail="Case type not found")
        return CaseTypePublic.model_validate(case_type)


# ---------------------------------------------------
# Case Stage Service
# ---------------------------------------------------

class CaseStageService:

    @staticmethod
    def get_all_case_stages(db: Session, sort: str | None = None) -> list[CaseStagePublic]:
        stages = CaseStageRepository.get_all(db, sort)
        return [CaseStagePublic.model_validate(s) for s in stages]

    @staticmethod
    def get_case_stage_by_id(db: Session, stage_id) -> CaseStagePublic:
        stage = CaseStageRepository.get_by_id(db, stage_id)
        if not stage:
            raise HTTPException(status_code=404, detail="Case stage not found")
        return CaseStagePublic.model_validate(stage)


# ---------------------------------------------------
# Case Status Service
# ---------------------------------------------------

class CaseStatusService:

    @staticmethod
    def get_all_case_statuses(db: Session, sort: str | None = None) -> list[CaseStatusPublic]:
        statuses = CaseStatusRepository.get_all(db, sort)
        return [CaseStatusPublic.model_validate(s) for s in statuses]

    @staticmethod
    def get_case_status_by_id(db: Session, status_id) -> CaseStatusPublic:
        status = CaseStatusRepository.get_by_id(db, status_id)
        if not status:
            raise HTTPException(status_code=404, detail="Case status not found")
        return CaseStatusPublic.model_validate(status)


# ---------------------------------------------------
# Case File Service
# ---------------------------------------------------

class CaseFileService:
    UPLOAD_DIR = "uploads/case_files"

    @staticmethod
    def create_case_file(
        db: Session, 
        case_id: UUID, 
        file: UploadFile, 
        
        ) -> CaseFilePublic:

        # Ensure upload folder exists
        os.makedirs(CaseFileService.UPLOAD_DIR, exist_ok=True)

        # Generate unique file name
        ext = os.path.splitext(file.filename)[1]
        unique_name = f"{uuid.uuid4()}{ext}"
        file_path = os.path.join(CaseFileService.UPLOAD_DIR, unique_name)

        # Save the file
        with open(file_path, "wb") as buffer:
            buffer.write(file.file.read())

        # Save file record in DB
        db_file = CaseFileRepository.create(db, {
            "case_id": case_id,
            "filename": file.filename,
            "file_url": file_path,
        })

        return CaseFilePublic.model_validate(db_file)

    @staticmethod
    def get_case_file_by_id(db: Session, file_id: UUID) -> CaseFilePublic:
        file = CaseFileRepository.get_by_id(db, file_id)
        if not file:
            raise HTTPException(status_code=404, detail="Case file not found")
        return CaseFilePublic.model_validate(file)

    @staticmethod
    def get_all_files_by_case(db: Session, case_id: UUID) -> list[CaseFilePublic]:
        files = CaseFileRepository.get_all_by_case(db, case_id)
        return [CaseFilePublic.model_validate(f) for f in files]

    @staticmethod
    def delete_case_file(db: Session, file_id: UUID) -> CaseFilePublic:
        file = CaseFileRepository.get_by_id(db, file_id)
        if not file:
            raise HTTPException(status_code=404, detail="Case file not found")

        # Remove physical file if exists
        if os.path.exists(file.file_url):
            os.remove(file.file_url)

        file_copy = CaseFilePublic.model_validate(file)
        CaseFileRepository.delete(db, file)
        return file_copy