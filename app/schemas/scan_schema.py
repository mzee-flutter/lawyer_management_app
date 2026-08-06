from datetime import date, time
from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from uuid import UUID


class ScanCaseCandidate(BaseModel):
    """One possible case match, shown to the lawyer when the extracted case
    number/title doesn't map cleanly to exactly one case."""
    case_id: UUID
    case_number: str
    first_party_name: str
    opposite_party_name: Optional[str] = None
    match_score: float  # 0.0 - 1.0, higher = closer match

    model_config = ConfigDict(from_attributes=True)


class ScanExtractionResponse(BaseModel):
    scan_id: UUID

    extracted_case_number: Optional[str] = None
    extracted_case_title: Optional[str] = None
    extracted_court_name: Optional[str] = None
    extracted_judge_name: Optional[str] = None
    extracted_hearing_date: Optional[str] = None   # "YYYY-MM-DD" — lawyer edits in UI
    extracted_hearing_time: Optional[str] = None   # "HH:MM" or null
    extraction_confidence: str                      # high | medium | low

    match_status: str                                # matched | ambiguous | unmatched
    matched_case: Optional[ScanCaseCandidate] = None
    candidate_cases: List[ScanCaseCandidate] = []

    image_url: str

    model_config = ConfigDict(from_attributes=True)


class ScanConfirmRequest(BaseModel):
    case_id: UUID
    hearing_date: date
    hearing_time: Optional[time] = None
    title: Optional[str] = None
    notes: Optional[str] = None


class ScanPublic(BaseModel):
    id: UUID
    status: str
    case_id: Optional[UUID] = None
    hearing_id: Optional[UUID] = None

    model_config = ConfigDict(from_attributes=True)