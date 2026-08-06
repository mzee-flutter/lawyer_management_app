# schemas/court_portal_schemas.py
#
# All Pydantic schemas for the Court Portal feature.
# Two domains:
#   1. CertifiedCopy — full CRUD schemas
#   2. BenchRoster   — read-only, derived from existing Case data

from datetime import datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field


# ══════════════════════════════════════════════════════════════
# CERTIFIED COPY SCHEMAS
# ══════════════════════════════════════════════════════════════

ALLOWED_COPY_STATUSES = {"applied", "processing", "ready"}

# Valid forward-only transitions:
#   applied → processing → ready
# Backward transitions are not allowed (legal documents don't un-process)
VALID_STATUS_TRANSITIONS = {
    "applied":    {"processing"},
    "processing": {"ready"},
    "ready":      set(),  # terminal state
}


class CertifiedCopyCreate(BaseModel):
    """Payload for POST /court/certified-copies"""
    case_id:          UUID
    reference_number: str  = Field(..., min_length=1, max_length=100)
    description:      Optional[str] = Field(None, max_length=500)


class CertifiedCopyUpdate(BaseModel):
    """
    Payload for PATCH /court/certified-copies/{id}
    Only status can be changed after creation.
    reference_number and description can also be corrected.
    """
    status:           Optional[str] = None
    reference_number: Optional[str] = Field(None, min_length=1, max_length=100)
    description:      Optional[str] = Field(None, max_length=500)

    model_config = ConfigDict(from_attributes=True)


class CertifiedCopyPublic(BaseModel):
    """Full response shape — returned by all endpoints"""
    id:               UUID
    case_id:          UUID
    reference_number: str
    description:      Optional[str]  = None
    status:           str

    applied_at:    Optional[datetime] = None
    processing_at: Optional[datetime] = None
    ready_at:      Optional[datetime] = None

    created_at: datetime
    updated_at: Optional[datetime] = None

    # Denormalised from Case — so the UI needs zero extra calls
    case_number:          str
    first_party_name:     str
    opposite_party_name:  Optional[str] = None
    court_name:           Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class CertifiedCopyListPublic(BaseModel):
    copies: list[CertifiedCopyPublic]
    total:  int

    model_config = ConfigDict(from_attributes=True)


# ══════════════════════════════════════════════════════════════
# BENCH ROSTER SCHEMAS
# Derived from existing Case data — no new DB table needed
# ══════════════════════════════════════════════════════════════

class RosterCaseItem(BaseModel):
    """One case row inside a bench card"""
    case_id:             str
    case_number:         str
    first_party_name:    str
    opposite_party_name: Optional[str] = None
    case_stage_name:     Optional[str] = None
    next_hearing_at:     Optional[datetime] = None   # nearest upcoming hearing

    model_config = ConfigDict(from_attributes=True)


class BenchCard(BaseModel):
    """
    One judge/court grouped card in the roster.
    Grouping key: (court_name, judge_name)
    """
    court_name:    str
    judge_name:    Optional[str] = None
    case_count:    int
    cases:         list[RosterCaseItem]

    model_config = ConfigDict(from_attributes=True)


class BenchRosterResponse(BaseModel):
    """
    Full roster response.
    benches — sorted by case_count descending (busiest court first).
    total_cases — lawyer's total active case count (for the header).
    """
    benches:     list[BenchCard]
    total_cases: int

    model_config = ConfigDict(from_attributes=True)