from fastapi import APIRouter, Depends, Query, UploadFile, File
from sqlalchemy.orm import Session
from uuid import UUID
from app.database.session import get_db
from app.schemas.case_schema import (
    CaseCreate,
    CaseUpdate,
    CasePublic,
    CourtCategoryPublic,
    CaseTypePublic,
    CaseStagePublic,
    CaseStatusPublic,
    CaseFileCreate,
    CaseFilePublic,
)
from app.services.case_service import (
    CaseService,
    CourtCategoryService,
    CaseTypeService,
    CaseStageService,
    CaseStatusService,
    CaseFileService,
)

router = APIRouter(prefix="/api/v1/cases", tags=["Cases"])

# ---------------------------------------------------
# Case Routes
# ---------------------------------------------------

@router.post("/", response_model=CasePublic)
def create_case(case_in: CaseCreate, db: Session = Depends(get_db)):
    """Create a new case"""
    return CaseService.create_case(db, case_in)


@router.get("/", response_model=list[CasePublic])
def list_cases(
    q: str | None = Query(None, description="Search cases by title or reference"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    sort: str | None = Query(None, description="Sort field, e.g. created_at,desc"),
    db: Session = Depends(get_db),
):
    return CaseService.search_cases(db, q=q, page=page, size=size, sort=sort)


@router.get("/archived", response_model=list[CasePublic])
def list_archived_cases(
    q: str | None = Query(None, description="Search archived cases"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    sort: str | None = Query(None, description="Sort field"),
    db: Session = Depends(get_db),
):
    return CaseService.search_archived_cases(db, q=q, page=page, size=size, sort=sort)


#This is endpoint to get all the categories here we place it because of it conflict with below enpoints
@router.get("/categories", response_model=list[CourtCategoryPublic])
def get_all_categories(db: Session = Depends(get_db)):
    
    return CourtCategoryService.get_all_categories(db)


@router.get("/{case_id}", response_model=CasePublic)
def get_case(case_id: UUID, db: Session = Depends(get_db)):
    return CaseService.get_case(db, case_id)


@router.patch("/{case_id}", response_model=CasePublic)
def update_case(case_id: UUID, case_in: CaseUpdate, db: Session = Depends(get_db)):
    return CaseService.update_case(db, case_id, case_in)


@router.delete("/{case_id}", response_model=CasePublic)
def archive_case(case_id: UUID, db: Session = Depends(get_db)):
    return CaseService.archive_case(db, case_id)


@router.put("/{case_id}/restore", response_model=CasePublic)
def restore_case(case_id: UUID, db: Session = Depends(get_db)):
    return CaseService.restore_case(db, case_id)


@router.delete("/{case_id}/permanent", response_model=CasePublic)
def delete_case_permanently(case_id: UUID, db: Session = Depends(get_db)):
    return CaseService.delete_case_permanently(db, case_id)

# ---------------------------------------------------
# Court Category Routes
# ---------------------------------------------------




@router.get("/categories/{category_id}", response_model=CourtCategoryPublic)
def get_category_by_id(category_id: UUID, db: Session = Depends(get_db)):
    return CourtCategoryService.get_category_by_id(db, category_id)


@router.get("/categories/{category_id}/subcategories", response_model=list[CourtCategoryPublic])
def get_subcategories(category_id: UUID, db: Session = Depends(get_db)):
    return CourtCategoryService.get_subcategories(db, category_id)

# ---------------------------------------------------
# Case Type Routes
# ---------------------------------------------------

@router.get("/types", response_model=list[CaseTypePublic])
def get_all_case_types(
    sort: str | None = Query(None, description="Sort case types"),
    db: Session = Depends(get_db),
):
    return CaseTypeService.get_all_case_types(db, sort)


@router.get("/types/{case_type_id}", response_model=CaseTypePublic)
def get_case_type_by_id(case_type_id: UUID, db: Session = Depends(get_db)):
    return CaseTypeService.get_case_type_by_id(db, case_type_id)

# ---------------------------------------------------
# Case Stage Routes
# ---------------------------------------------------

@router.get("/stages", response_model=list[CaseStagePublic])
def get_all_case_stages(
    sort: str | None = Query(None, description="Sort stages"),
    db: Session = Depends(get_db),
):
    return CaseStageService.get_all_case_stages(db, sort)


@router.get("/stages/{stage_id}", response_model=CaseStagePublic)
def get_case_stage_by_id(stage_id: UUID, db: Session = Depends(get_db)):
    return CaseStageService.get_case_stage_by_id(db, stage_id)

# ---------------------------------------------------
# Case Status Routes
# ---------------------------------------------------

@router.get("/statuses", response_model=list[CaseStatusPublic])
def get_all_case_statuses(
    sort: str | None = Query(None, description="Sort statuses"),
    db: Session = Depends(get_db),
):
    return CaseStatusService.get_all_case_statuses(db, sort)


@router.get("/statuses/{status_id}", response_model=CaseStatusPublic)
def get_case_status_by_id(status_id: UUID, db: Session = Depends(get_db)):
    return CaseStatusService.get_case_status_by_id(db, status_id)

# ---------------------------------------------------
# Case File Routes
# ---------------------------------------------------

@router.post("/{case_id}/files", response_model=CaseFilePublic)
def create_case_file(case_id: UUID, file_in: CaseFileCreate, db: Session = Depends(get_db)):
    """Create a new file for a specific case"""
    file_in.case_id = case_id
    return CaseFileService.create_case_file(db, file_in)


@router.get("/{case_id}/files", response_model=list[CaseFilePublic])
def get_all_case_files(case_id: UUID, db: Session = Depends(get_db)):
    """List all files for a specific case"""
    return CaseFileService.get_all_files_by_case(db, case_id)


@router.get("/files/{file_id}", response_model=CaseFilePublic)
def get_case_file_by_id(file_id: UUID, db: Session = Depends(get_db)):
    """Get a specific case file by ID"""
    return CaseFileService.get_case_file_by_id(db, file_id)


@router.delete("/files/{file_id}", response_model=CaseFilePublic)
def delete_case_file(file_id: UUID, db: Session = Depends(get_db)):
    """Delete a case file"""
    return CaseFileService.delete_case_file(db, file_id)




# The Tables become droped and i have to Insert the data in the tables and test the List of cases