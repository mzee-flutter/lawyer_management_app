# schemas/legal_task_schemas.py
#
# All Pydantic schemas for the Legal Task Board feature.
# Follows the exact style of your HearingPublic / TodayHearingResponse.

from datetime import datetime, timezone
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field, field_validator


ALLOWED_PRIORITIES = {"high", "medium", "low"}

# Priority sort weights — used in service layer for ordering
PRIORITY_ORDER = {"high": 0, "medium": 1, "low": 2}


# ══════════════════════════════════════════════════════════════
# REQUEST SCHEMAS
# ══════════════════════════════════════════════════════════════

class LegalTaskCreate(BaseModel):
    """POST /tasks/"""
    case_id:           UUID
    task_title:        str  = Field(..., min_length=1, max_length=300)
    notes:             Optional[str]      = Field(None, max_length=1000)
    priority:          str                = Field(default="medium")
    due_date:          Optional[datetime] = None
    is_auto_generated: bool               = False
    source_hearing_id: Optional[UUID]     = None

    model_config = ConfigDict(from_attributes=True)

    @field_validator('due_date')
    def ensure_timezone(cls, v):
        if v is None:
            return v
        if v.tzinfo is None:
            return v.replace(tzinfo=timezone.utc)
        return v


class LegalTaskUpdate(BaseModel):
    """PATCH /tasks/{id} — all fields optional"""
    task_title:   Optional[str]      = Field(None, min_length=1, max_length=300)
    notes:        Optional[str]      = Field(None, max_length=1000)
    priority:     Optional[str]      = None
    due_date:     Optional[datetime] = None
    is_completed: Optional[bool]     = None

    model_config = ConfigDict(from_attributes=True)

    @field_validator('due_date')
    def ensure_timezone(cls, v):
        if v is None:
            return v
        if v.tzinfo is None:
            return v.replace(tzinfo=timezone.utc)
        return v


# ══════════════════════════════════════════════════════════════
# RESPONSE SCHEMAS
# ══════════════════════════════════════════════════════════════

class LegalTaskPublic(BaseModel):
    """Full task response — returned by all endpoints"""
    id:      UUID
    case_id: UUID

    task_title:        str
    notes:             Optional[str]  = None
    priority:          str
    due_date:          Optional[datetime] = None

    is_completed:      bool
    completed_at:      Optional[datetime] = None
    is_auto_generated: bool
    source_hearing_id: Optional[UUID] = None

    created_at: datetime
    updated_at: Optional[datetime] = None

    # Denormalised from Case — UI needs zero extra calls
    case_number:         str
    first_party_name:    str
    opposite_party_name: Optional[str] = None
    court_name:          Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class TaskBucketResponse(BaseModel):
    """
    Bucketed task list for the dashboard / task board.
    Computed server-side using the lawyer's timezone.

    overdue   — due_date < today  AND  not completed
    this_week — due_date in [today, today+7]  AND  not completed
    upcoming  — due_date > today+7  AND  not completed
    no_date   — due_date is NULL  AND  not completed
    completed — is_completed = True (last 30 days)

    Within each bucket: sorted by priority (high→medium→low),
    then by due_date ascending.
    """
    overdue:   list[LegalTaskPublic]
    this_week: list[LegalTaskPublic]
    upcoming:  list[LegalTaskPublic]
    no_date:   list[LegalTaskPublic]
    completed: list[LegalTaskPublic]

    # Counts — for badge display on tab bar / notification bell
    overdue_count:   int
    this_week_count: int
    total_open:      int

    model_config = ConfigDict(from_attributes=True)