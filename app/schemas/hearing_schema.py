from datetime import datetime, timezone, date
from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict
from uuid import UUID


ALLOWED_HEARING_STATUSES = {
    "scheduled",
    "completed",
    "adjourned",
    "cancelled",
}


class HearingBase(BaseModel):
    title: str = Field(..., min_length=1)
    hearing_datetime: datetime
    notes: Optional[str] = None
    has_specific_time: bool = False

    @field_validator('hearing_datetime')
    def ensure_timezone(cls, v):
        if v.tzinfo is None:
            return v.replace(tzinfo=timezone.utc)
        return v


class HearingCreate(HearingBase):
    model_config = ConfigDict(from_attributes=True)


class HearingUpdate(BaseModel):
    title: Optional[str] = None
    hearing_datetime: Optional[datetime] = None
    notes: Optional[str] = None
    status: Optional[str] = None
    has_specific_time: bool = False
    adjournment_reason: Optional[str] = Field(None, max_length=500)
    adjournment_date: Optional[date] = None

    @field_validator("hearing_datetime")
    def ensure_timezone(cls, v):
        if v is None:
            return v
        if v.tzinfo is None:
            return v.replace(tzinfo=timezone.utc)
        return v

    @field_validator("status")
    def validate_status(cls, v):
        if v and v not in ALLOWED_HEARING_STATUSES:
            raise ValueError("Invalid hearing status")
        return v


class HearingPublic(HearingBase):
    id: UUID
    case_id: UUID
    status: str
    created_at: datetime
    updated_at: Optional[datetime] = None
    adjournment_reason: Optional[str] = None
    adjournment_date: Optional[date] = None

    model_config = ConfigDict(from_attributes=True)


class HearingListPublic(BaseModel):
    hearings: List[HearingPublic]
    model_config = ConfigDict(from_attributes=True)


class TodayHearingResponse(BaseModel):
    id: UUID
    case_id: UUID
    title: str
    hearing_datetime: datetime
    has_specific_time: bool = False
    # "none" | "soft" | "hard" — computed per calendar day, not per hearing
    # in isolation. See HearingService._classify_day.
    conflict_level: str = "none"
    notes: Optional[str]
    status: str
    created_at: datetime
    updated_at: Optional[datetime]

    court_name: Optional[str]
    judge_name: Optional[str]
    first_party_name: str
    opposite_party_name: Optional[str]
    case_stage_name: Optional[str]
    case_number: str

    days_until_hearing: int

    class Config:
        from_attributes = True


class CalendarHearingItem(BaseModel):
    id: str
    case_id: str
    title: str
    hearing_datetime: datetime
    has_specific_time: bool = False
    status: str
    notes: Optional[str] = None
    court_name: Optional[str] = None
    judge_name: Optional[str] = None
    first_party_name: str
    opposite_party_name: Optional[str] = None
    case_stage_name: Optional[str] = None
    case_number: str
    model_config = ConfigDict(from_attributes=True)


class CalendarDayResponse(BaseModel):
    date: date
    hearings: list[CalendarHearingItem]
    has_conflict: bool
    # New: true when the day has a "soft" risk (untimed overlap, or heavy
    # same-day workload) but no hard time-overlap. A day is never both —
    # hard conflict takes priority and soft is left false in that case.
    has_soft_conflict: bool = False
    # Short human-readable reasons the day was flagged soft, e.g.
    # ["2 hearings without a specific time"]. Empty when not soft-flagged.
    conflict_reasons: list[str] = Field(default_factory=list)
    has_adjourned: bool
    hearing_count: int
    model_config = ConfigDict(from_attributes=True)


class CalendarMonthResponse(BaseModel):
    year: int
    month: int
    days: list[CalendarDayResponse]
    model_config = ConfigDict(from_attributes=True)


class AdjournmentEntry(BaseModel):
    id: str
    case_id: str
    title: str
    adjournment_date: Optional[date] = None
    adjournment_reason: Optional[str] = None
    hearing_datetime: datetime
    rescheduled_to: Optional[datetime] = None
    model_config = ConfigDict(from_attributes=True)


class AdjournmentHistoryResponse(BaseModel):
    case_id: str
    case_number: str
    first_party_name: str
    opposite_party_name: Optional[str] = None
    total_adjournments: int
    adjournments: list[AdjournmentEntry]
    model_config = ConfigDict(from_attributes=True)