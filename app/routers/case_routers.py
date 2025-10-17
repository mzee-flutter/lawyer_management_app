from fastapi import APIRouter, Depends, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
from uuid import UUID
from fastapi import Request
from app.database.session import get_db
from app.schemas.case_schema import (
    CaseCreate, CaseUpdate, CasePublic,
    CourtCategoryPublic, CaseTypePublic,
    CaseStagePublic, CaseStatusPublic,
    CaseFileCreate, CaseFilePublic
)
from app.services.case_service import (
    CaseService, CourtCategoryService,
    CaseTypeService, CaseStageService,
    CaseStatusService, CaseFileService
)

router = APIRouter(prefix="/api/v1/cases", tags=["Cases"])

# ---------------------------------------------------
# 🔹 CASES ROUTES
# ---------------------------------------------------

@router.post("/", response_model=CasePublic)
def create_case(case_in: CaseCreate, db: Session = Depends(get_db)):
    return CaseService.create_case(db, case_in)



@router.get("/", response_model=list[CasePublic])
def list_cases(
     q: str | None = Query(None, description="Search cases by title or reference"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    sort: str | None = Query(None, description="Sort field, e.g. created_at,desc"),
    db: Session = Depends(get_db),

    request: Request = None,
   
):
    return CaseService.search_cases(db, request, q, page, size, sort)

@router.get("/archived", response_model=list[CasePublic])
def list_archived_cases(
    q: str | None = Query(None, description="Search archived cases"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    sort: str | None = Query(None, description="Sort field"),
    db: Session = Depends(get_db),
):
    return CaseService.search_archived_cases(db, q=q, page=page, size=size, sort=sort)


# ---------------------------------------------------
# 🔹 COURT CATEGORY ROUTES
# ---------------------------------------------------

@router.get("/categories", response_model=list[CourtCategoryPublic])
def get_all_categories(db: Session = Depends(get_db)):
    """Get all main court categories"""
    return CourtCategoryService.get_all_categories(db)


@router.get("/categories/{category_id}", response_model=CourtCategoryPublic)
def get_category_by_id(category_id: UUID, db: Session = Depends(get_db)):
    """Get a main court category by ID"""
    return CourtCategoryService.get_category_by_id(db, category_id)


@router.get("/categories/{category_id}/subcategories", response_model=list[CourtCategoryPublic])
def get_subcategories(category_id: UUID, db: Session = Depends(get_db)):
    """Get all subcategories of a given court category"""
    return CourtCategoryService.get_subcategories(db, category_id)


# ---------------------------------------------------
# 🔹 CASE TYPE ROUTES
# ---------------------------------------------------

@router.get("/types", response_model=list[CaseTypePublic])
def get_all_case_types(db: Session = Depends(get_db)):
    """Get all case types"""
    return CaseTypeService.get_all_case_types(db)


@router.get("/types/{case_type_id}", response_model=CaseTypePublic)
def get_case_type_by_id(case_type_id: UUID, db: Session = Depends(get_db)):
    """Get case type by ID"""
    return CaseTypeService.get_case_type_by_id(db, case_type_id)


# ---------------------------------------------------
# 🔹 CASE STAGE ROUTES
# ---------------------------------------------------

@router.get("/stages", response_model=list[CaseStagePublic])
def get_all_case_stages(db: Session = Depends(get_db)):
    """Get all case stages"""
    return CaseStageService.get_all_case_stages(db)


@router.get("/stages/{stage_id}", response_model=CaseStagePublic)
def get_case_stage_by_id(stage_id: UUID, db: Session = Depends(get_db)):
    """Get case stage by ID"""
    return CaseStageService.get_case_stage_by_id(db, stage_id)


# ---------------------------------------------------
# 🔹 CASE STATUS ROUTES
# ---------------------------------------------------

@router.get("/statuses", response_model=list[CaseStatusPublic])
def get_all_case_statuses(db: Session = Depends(get_db)):
    """Get all case statuses"""
    return CaseStatusService.get_all_case_statuses(db)


@router.get("/statuses/{status_id}", response_model=CaseStatusPublic)
def get_case_status_by_id(status_id: UUID, db: Session = Depends(get_db)):
    """Get case status by ID"""
    return CaseStatusService.get_case_status_by_id(db, status_id)


# ---------------------------------------------------
# 🔹 CASE FILE ROUTES
# ---------------------------------------------------

@router.post("/{case_id}/files", response_model=CaseFilePublic)
def upload_case_file(
    case_id: UUID,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    request: Request = None, 
):
    """Upload a new file for a specific case"""
    return CaseFileService.create_case_file(db, case_id, file, request)


@router.get("/{case_id}/files", response_model=list[CaseFilePublic])
def get_case_files(case_id: UUID, db: Session = Depends(get_db), request: Request = None):
    """List all files for a specific case"""
    return CaseFileService.get_all_files_by_case(db, case_id, request)


@router.get("/files/{file_id}", response_model=CaseFilePublic)
def get_case_file(file_id: UUID, db: Session = Depends(get_db), request: Request = None):
    """Get a specific case file by ID"""
    return CaseFileService.get_case_file_by_id(db, file_id, request)


@router.delete("/files/{file_id}", response_model=CaseFilePublic)
def delete_case_file(file_id: UUID, db: Session = Depends(get_db)):
    """Delete a specific case file"""
    return CaseFileService.delete_case_file(db, file_id)


# ---------------------------------------------------
# 🔹 CASE MANAGEMENT ROUTES (AFTER ALL STATIC ONES)
# ---------------------------------------------------

@router.get("/{case_id}", response_model=CasePublic)
def get_case(case_id: UUID, db: Session = Depends(get_db), request: Request = None):
    return CaseService.get_case(db, case_id, request)

@router.patch("/{case_id}", response_model=CasePublic)
def update_case(case_id: UUID, case_in: CaseUpdate, db: Session = Depends(get_db)):
    """Update a case"""
    return CaseService.update_case(db, case_id, case_in)


@router.delete("/{case_id}", response_model=CasePublic)
def archive_case(case_id: UUID, db: Session = Depends(get_db)):
    """Archive a case"""
    return CaseService.archive_case(db, case_id)


@router.put("/{case_id}/restore", response_model=CasePublic)
def restore_case(case_id: UUID, db: Session = Depends(get_db)):
    """Restore an archived case"""
    return CaseService.restore_case(db, case_id)


@router.delete("/{case_id}/permanent", response_model=CasePublic)
def delete_case_permanently(case_id: UUID, db: Session = Depends(get_db)):
    """Permanently delete a case"""
    return CaseService.delete_case_permanently(db, case_id)
