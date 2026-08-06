from unittest import case
from sqlalchemy.orm import Session
import os
import socket
from fastapi import HTTPException, status
import uuid
from uuid import UUID
from fastapi import UploadFile, Request
from datetime import datetime, timezone, timedelta

from app.models.auth_model import User
from app.repositories.case_repository import (
    CaseRepository,
    CourtCategoryRepository,
    CaseTypeRepository,
    CaseStageRepository,
    CaseStatusRepository,
    CaseFileRepository,
    CaseRelatedClientRepository,
)
from app.repositories.client_repository import ClientRepository 
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
    CaseRelatedClientCreate,
    CaseRelatedClientPublic,
    CaseRelatedClientBatchCreate,
   
)
from app.schemas.hearing_schema import TodayHearingResponse
# -------------------------
# Helpers: detect server IP and build URLs
# -------------------------
def detect_server_ip() -> str:
    """
    Return the server's likely LAN IP (not 127.0.0.1).
    Uses a UDP socket trick that does not actually send data.
    """
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            # connect to an external IP — no packets are actually sent
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            return ip
    except Exception:
        # fallback
        return "127.0.0.1"


def get_base_url(request: Request) -> str:
    """
    Returns the client-reachable base URL.
    Works correctly behind proxies, Docker, and locally.
    """
    return str(request.base_url).rstrip("/")



def build_file_url(request: Request, file_path: str) -> str:
    if not file_path:
        return file_path

    # Already a full URL
    if file_path.startswith(("http://", "https://")):
        return file_path

    base_url = str(request.base_url).rstrip("/")
    normalized = file_path.replace("\\", "/")

    return f"{base_url}/{normalized.lstrip('/')}"


# ---------------------------------------------------
# Case Service
# ---------------------------------------------------
class CaseService:

    @staticmethod
    def create_case(db: Session, case_in: CaseCreate, user_id: UUID) -> CasePublic:
        case = CaseRepository.create(db, case_in, user_id)
        return CasePublic.model_validate(case)

    @staticmethod
    def get_case(db: Session, case_id: UUID,user_id:UUID, request: Request) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        case_data = CasePublic.model_validate(case)

        # fix file URLs in 'files' (if present)
        if getattr(case_data, "files", None):
            for f in case_data.files:
                f.file_url = build_file_url(request, f.file_url)

        return case_data

    @staticmethod
    def search_cases(
        db: Session,
        request: Request,
        user_id:UUID,
        q: str | None = None,
        page: int = 1,
        size: int = 10,
        sort: str | None = None,
    ) -> list[CasePublic]:
        skip = (page - 1) * size
        cases = CaseRepository.search(db,user_id=user_id, query=q, skip=skip, limit=size, sort=sort)

        result = []
        for c in cases:
            case_data = CasePublic.model_validate(c)
            if getattr(case_data, "files", None):
                for f in case_data.files:
                    f.file_url = build_file_url(request, f.file_url)
            result.append(case_data)

        return result

    @staticmethod
    def search_archived_cases(
        db: Session,
        request: Request,
        user_id:UUID,
        q: str | None = None,
        page: int = 1,
        size: int = 10,
        sort: str | None = None,
    ) -> list[CasePublic]:
        skip = (page - 1) * size
        cases = CaseRepository.search_archived(db, user_id=user_id, query=q, skip=skip, limit=size, sort=sort)

        result = []
        for c in cases:
            case_data = CasePublic.model_validate(c)
            if getattr(case_data, "files", None):
                for f in case_data.files:
                    f.file_url = build_file_url(request, f.file_url)
            result.append(case_data)

        return result

    def update_case(db: Session, case_id: UUID, case_in: CaseUpdate, user_id:UUID) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        updated = CaseRepository.update(db, case, case_in)
        return CasePublic.model_validate(updated)

    def archive_case(db: Session, case_id: UUID, user_id:UUID) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        archived = CaseRepository.archive(db, case)
        return CasePublic.model_validate(archived)

    def restore_case(db: Session, case_id: UUID, user_id:UUID) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        if case.archived_at is None:
            raise HTTPException(status_code=400, detail="Case is not archived")
        restored = CaseRepository.restore(db, case)
        return CasePublic.model_validate(restored)

    def delete_case_permanently(db: Session, case_id: UUID, user_id:UUID) -> CasePublic:
        case = CaseRepository.get_by_id(db, case_id,user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        case_copy = CasePublic.model_validate(case)
        CaseRepository.delete(db, case)
        return case_copy



# ---------------------------------------------------
# Case Related Clients Service
# ---------------------------------------------------
class CaseRelatedClientService:

#add one or many clients to case
    @staticmethod
    def add_many_related_clients(
        db: Session,
        case_id: UUID,
        payload: CaseRelatedClientBatchCreate,
        user_id: UUID
    ) -> list[CaseRelatedClientPublic]:
        # ensure case exists
        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        
        # IMPORTANT: without this check, a user could attach another lawyer's
        # client to their own case just by guessing/enumerating a client_id.
        for item in payload.items:
            client = ClientRepository.get_by_id(db, item.client_id, user_id)
            if not client:
                raise HTTPException(status_code=404, detail=f"Client {item.client_id} not found")

        # convert payload.items to list[dict] for repo
        items = [item.model_dump() for item in payload.items]
        created = CaseRelatedClientRepository.add_many_related_clients(db, case_id, user_id, items)

        return [CaseRelatedClientPublic.model_validate(rc) for rc in created]

    @staticmethod
    def get_all_related_clients(
        db: Session,
        case_id: UUID,
        user_id: UUID
    ) -> list[CaseRelatedClientPublic]:

        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        clients = CaseRelatedClientRepository.get_all_for_case(db, case_id, user_id)

        return [CaseRelatedClientPublic.model_validate(rc) for rc in clients]

    @staticmethod
    def get_related_client(
        db: Session,
        related_id: UUID,
        user_id:UUID
    ) -> CaseRelatedClientPublic:

        rc = CaseRelatedClientRepository.get_by_id(db, related_id, user_id)
        if not rc:
            raise HTTPException(status_code=404, detail="Related client not found")

        return CaseRelatedClientPublic.model_validate(rc)

    @staticmethod
    def update_related_client(
        db: Session,
        related_id: UUID,
        role: str | None,
        user_id:UUID
    ) -> CaseRelatedClientPublic:

        rc = CaseRelatedClientRepository.get_by_id(db, related_id, user_id)
        if not rc:
            raise HTTPException(status_code=404, detail="Related client not found")

        updated = CaseRelatedClientRepository.update(db, rc, role)

        return CaseRelatedClientPublic.model_validate(updated)

    @staticmethod
    def delete_related_client(
        db: Session,
        related_id: UUID,
        user_id: UUID
    ) -> CaseRelatedClientPublic:

        rc = CaseRelatedClientRepository.get_by_id(db, related_id, user_id)
        if not rc:
            raise HTTPException(status_code=404, detail="Related client not found")

        rc_copy = CaseRelatedClientPublic.model_validate(rc)

        CaseRelatedClientRepository.delete(db, rc)

        return rc_copy


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
        request: Request,
        user_id:UUID
    ) -> CaseFilePublic:
        case = CaseRepository.get_by_id(db, case_id, user_id)   # ownership gate
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        
        os.makedirs(CaseFileService.UPLOAD_DIR, exist_ok=True)

        ext = os.path.splitext(file.filename)[1]
        unique_name = f"{uuid.uuid4()}{ext}"
        file_path = os.path.join(CaseFileService.UPLOAD_DIR, unique_name)

        
        with open(file_path, "wb") as buffer:
            buffer.write(file.file.read())

        db_file = CaseFileRepository.create(db, {
            "user_id":user_id,
            "case_id": case_id,
            "filename": file.filename,
            "file_url": file_path,
        })

        public_url = build_file_url(request, file_path)

        # 3. Return response
        return CaseFilePublic(
            id=db_file.id,
            case_id=db_file.case_id,
            filename=db_file.filename,
            file_url=public_url,
            uploaded_at=db_file.uploaded_at,
        )

    # method for one or more file to add to case at once.
    @staticmethod
    def create_many_files(
        db: Session,
        case_id: UUID,
        files: list[UploadFile],
        request: Request,
        user_id: UUID
    ) -> list[CaseFilePublic]:
        
        case= CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail= "Case not found")
        
        os.makedirs(CaseFileService.UPLOAD_DIR, exist_ok=True)
        file_paths = []

        try:
            file_records = []
            
            for file in files:
                ext = os.path.splitext(file.filename)[1]
                unique_name = f"{uuid.uuid4()}{ext}"
                file_path = os.path.join(CaseFileService.UPLOAD_DIR, unique_name)

                with open(file_path, "wb") as buffer:
                    buffer.write(file.file.read())

                file_records.append({
                    "user_id":user_id,
                    "case_id": case_id,
                    "filename": file.filename,
                    "file_url": file_path,
                })
                
                file_paths.append(file_path)

          
            created_rows = CaseFileRepository.create_many(db, file_records)
            db.commit()

        except Exception as e:
            
            for path in file_paths:
                if os.path.exists(path):
                    os.remove(path)

            raise e

        public_list = [
            CaseFilePublic(
                id=row.id,
                case_id=row.case_id,
                filename=row.filename,
                file_url=build_file_url(request, row.file_url),
                uploaded_at=row.uploaded_at,
            )
            for row in created_rows
        ]

        return public_list

    @staticmethod
    def get_all_files_by_case(db: Session, case_id: UUID, request: Request,user_id: UUID) -> list[CaseFilePublic]:
        case= CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        files = CaseFileRepository.get_all_by_case(db, case_id, user_id)
        return [
            CaseFilePublic(
                id=f.id,
                case_id=f.case_id,
                filename=f.filename,
                file_url=build_file_url(request, f.file_url),
                uploaded_at=f.uploaded_at,
            )
            for f in files
        ]

    @staticmethod
    def get_case_file_by_id(db: Session, file_id: UUID, request: Request, user_id: UUID) -> CaseFilePublic:
        file = CaseFileRepository.get_by_id(db, file_id, user_id)
        if not file:
            raise HTTPException(status_code=404, detail="Case file not found")

        return CaseFilePublic(
            id=file.id,
            case_id=file.case_id,
            filename=file.filename,
            file_url=build_file_url(request, file.file_url),
            uploaded_at=file.uploaded_at,
        )

    @staticmethod
    def delete_case_file(db: Session, file_id: UUID, user_id:UUID) -> CaseFilePublic:
        file = CaseFileRepository.get_by_id(db, file_id, user_id)
        if not file:
            raise HTTPException(status_code=404, detail="Case file not found")

        # 1. Delete physical file
        if os.path.exists(file.file_url):
            os.remove(file.file_url)

        # 2. Delete DB record
        file_copy = CaseFilePublic.model_validate(file)
        CaseFileRepository.delete(db, file)
        return file_copy




