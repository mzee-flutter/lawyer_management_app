from typing import Optional, List, Any
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field


# -----------------------------
#  Court Category Schemas
# -----------------------------
class CourtCategoryBase(BaseModel):
    name: str
    parent_id: Optional[UUID] = None


class CourtCategoryCreate(CourtCategoryBase):
    pass


class CourtCategoryUpdate(BaseModel):
    name: Optional[str] = None
    parent_id: Optional[UUID] = None


class CourtCategoryPublic(CourtCategoryBase):
    id: UUID
    subcategories: Optional[List["CourtCategoryPublic"]] = []

    class Config:
        from_attributes = True


# -----------------------------
#  Case Type Schemas
# -----------------------------
class CaseTypeBase(BaseModel):
    name: str


class CaseTypeCreate(CaseTypeBase):
    pass


class CaseTypeUpdate(BaseModel):
    name: Optional[str] = None


class CaseTypePublic(CaseTypeBase):
    id: UUID

    class Config:
        from_attributes= True


# -----------------------------
#  Case Stage Schemas
# -----------------------------
class CaseStageBase(BaseModel):
    name: str


class CaseStageCreate(CaseStageBase):
    pass


class CaseStageUpdate(BaseModel):
    name: Optional[str] = None


class CaseStagePublic(CaseStageBase):
    id: UUID

    class Config:
        from_attributes = True


# -----------------------------
#  Case Status Schemas
# -----------------------------
class CaseStatusBase(BaseModel):
    name: str


class CaseStatusCreate(CaseStatusBase):
    pass


class CaseStatusUpdate(BaseModel):
    name: Optional[str] = None


class CaseStatusPublic(CaseStatusBase):
    id: UUID

    class Config:
        from_attributes = True


# -----------------------------
#  Case File Schemas
# -----------------------------
class CaseFileBase(BaseModel):
    filename: str
    file_url: str


class CaseFileCreate(CaseFileBase):
    pass
    


class CaseFilePublic(BaseModel):
    id: UUID
    case_id: UUID
    filename: str
    file_url: str
    uploaded_at: datetime
    

    class Config:
        from_attributes = True



# -----------------------------
#  Case Schemas
# -----------------------------
class CaseBase(BaseModel):
    case_number: str
    registration_date: datetime
    court_name: Optional[str] = None
    judge_name: Optional[str] = None
    first_party_id: UUID
    second_party_id:UUID
    opposite_party_name: Optional[str] = None
    court_category_id: UUID
    case_type_id: UUID
    case_stage_id: UUID
    case_status_id: UUID
    case_notes: Optional[str] = None
    related_files: Optional[List[Any]] = None
    legal_fees: Optional[float] = None
    status: Optional[str] = "active"


class CaseCreate(CaseBase):
    pass


class CaseUpdate(BaseModel):
    case_stage_id: Optional[UUID] = None
    case_status_id: Optional[UUID] = None
    case_notes: Optional[str] = None
    related_files: Optional[List[Any]] = None
    legal_fees: Optional[float] = None
    status: Optional[str] = None
    archived_at: Optional[datetime] = None


class CasePublic(CaseBase):
    id: UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    archived_at: Optional[datetime] = None
    court_category: Optional[CourtCategoryPublic] = None
    case_type: Optional[CaseTypePublic] = None
    case_stage: Optional[CaseStagePublic] = None
    case_status: Optional[CaseStatusPublic] = None
    files: Optional[List[CaseFilePublic]] = None

    class Config:
        from_attributes = True
