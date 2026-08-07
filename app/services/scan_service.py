import os
import uuid
from datetime import datetime, timezone, time as dt_time
from difflib import SequenceMatcher
from zoneinfo import ZoneInfo
from uuid import UUID

from fastapi import UploadFile, Request, HTTPException
from sqlalchemy.orm import Session

from app.models.case_model import Case
from app.repositories.case_repository import CaseRepository
from app.repositories.scan_repository import ScanRepository
from app.schemas.scan_schema import (
    ScanExtractionResponse, ScanCaseCandidate, ScanConfirmRequest, ScanPublic
)
from app.schemas.hearing_schema import HearingCreate, HearingPublic
from app.services.hearing_service import HearingService
from app.services.vision_extraction_client import extract_hearing_fields, VisionExtractionError
from app.services.case_service import build_file_url
from app.core.notification_settings import APP_LOCAL_TIMEZONE

_LOCAL_TZ = ZoneInfo(APP_LOCAL_TIMEZONE)

# Below this, a title isn't even shown as a candidate — too dissimilar to
# be worth the lawyer's attention.
_TITLE_MATCH_THRESHOLD = 0.55
# Above this, AND clearly ahead of the runner-up, we pre-select it — but
# the lawyer can still change it on the confirmation screen either way.
_CONFIDENT_MATCH_THRESHOLD = 0.82


def _normalize_case_number(value: str | None) -> str:
    if not value:
        return ""
    return "".join(ch for ch in value.upper() if ch.isalnum())


def _title_similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, a.lower().strip(), b.lower().strip()).ratio()


def _match_case(db: Session, user_id: UUID, case_number: str | None, case_title: str | None):
    """
    Returns (match_status, matched: tuple[Case, float] | None, candidates: list[tuple[Case, float]]).
    Only ever searches within this lawyer's own active cases — never across users.
    """
    active_cases = CaseRepository.search(db, user_id=user_id, query=None, skip=0, limit=1000)

    # 1. Exact case-number match wins outright — case numbers are unique
    #    court identifiers, so this is the strongest possible signal.
    normalized_target = _normalize_case_number(case_number)
    if normalized_target:
        for case in active_cases:
            if _normalize_case_number(case.case_number) == normalized_target:
                return "matched", (case, 1.0), []

    # 2. Fall back to fuzzy title matching — common when OCR/the model
    #    misreads a digit in the case number, or the document has no
    #    case number printed on it at all.
    if not case_title:
        return "unmatched", None, []

    scored = []
    for case in active_cases:
        title = f"{case.first_party_name} vs {case.opposite_party_name or ''}".strip()
        score = _title_similarity(case_title, title)
        if score >= _TITLE_MATCH_THRESHOLD:
            scored.append((case, score))

    if not scored:
        return "unmatched", None, []

    scored.sort(key=lambda pair: pair[1], reverse=True)
    top_case, top_score = scored[0]

    if top_score >= _CONFIDENT_MATCH_THRESHOLD and (
        len(scored) == 1 or top_score - scored[1][1] > 0.1
    ):
        return "matched", (top_case, top_score), []

    # Several plausible cases — let the lawyer pick, never guess silently.
    return "ambiguous", None, scored[:5]


def _to_candidate(case: Case, score: float) -> ScanCaseCandidate:
    return ScanCaseCandidate(
        case_id=case.id,
        case_number=case.case_number,
        first_party_name=case.first_party_name,
        opposite_party_name=case.opposite_party_name,
        match_score=round(score, 2),
    )


class ScanService:
    UPLOAD_DIR = "uploads/scanned_documents"

    @staticmethod
    async def extract_from_image(
        db: Session,
        image: UploadFile,
        request: Request,
        user_id: UUID,
    ) -> ScanExtractionResponse:

        os.makedirs(ScanService.UPLOAD_DIR, exist_ok=True)

        ext = os.path.splitext(image.filename or "")[1] or ".jpg"
        unique_name = f"{uuid.uuid4()}{ext}"
        file_path = os.path.join(ScanService.UPLOAD_DIR, unique_name)

        image_bytes = await image.read()
        with open(file_path, "wb") as buffer:
            buffer.write(image_bytes)

        try:
            extracted = await extract_hearing_fields(
                image_bytes, mime_type=image.content_type or "image/jpeg"
            )
        except VisionExtractionError as e:
            # The photo is saved either way — keep the row so the lawyer's
            # upload isn't silently lost and it shows up in support logs
            # rather than as a bare 500.
            ScanRepository.create(db, {
                "user_id": user_id,
                "image_url": file_path,
                "extraction_confidence": "low",
                "raw_model_text": str(e),
                "match_status": "unmatched",
                "status": "pending",
            })
            raise HTTPException(
                status_code=502,
                detail=f"Couldn't read the document. Please retake the photo and try again. ({e})",
            )

        match_status, matched, candidates = _match_case(
            db, user_id, extracted.get("case_number"), extracted.get("case_title")
        )

        scan = ScanRepository.create(db, {
            "user_id": user_id,
            "case_id": matched[0].id if matched else None,
            "image_url": file_path,
            "extracted_case_number": extracted.get("case_number"),
            "extracted_case_title": extracted.get("case_title"),
            "extracted_court_name": extracted.get("court_name"),
            "extracted_judge_name": extracted.get("judge_name"),
            "extracted_hearing_date": extracted.get("hearing_date"),
            "extracted_hearing_time": extracted.get("hearing_time"),
            "extraction_confidence": extracted.get("confidence", "low"),
            "raw_model_text": extracted.get("raw_model_text"),
            "match_status": match_status,
            "status": "pending",
        })

        return ScanExtractionResponse(
            scan_id=scan.id,
            extracted_case_number=extracted.get("case_number"),
            extracted_case_title=extracted.get("case_title"),
            extracted_court_name=extracted.get("court_name"),
            extracted_judge_name=extracted.get("judge_name"),
            extracted_hearing_date=extracted.get("hearing_date"),
            extracted_hearing_time=extracted.get("hearing_time"),
            extraction_confidence=extracted.get("confidence", "low"),
            match_status=match_status,
            matched_case=_to_candidate(*matched) if matched else None,
            candidate_cases=[_to_candidate(c, s) for c, s in candidates],
            image_url=build_file_url(request, file_path),
        )

    @staticmethod
    def confirm_scan(
        db: Session,
        scan_id: UUID,
        confirm_in: ScanConfirmRequest,
        user_id: UUID,
    ) -> HearingPublic:

        scan = ScanRepository.get_by_id(db, scan_id, user_id)
        if not scan:
            raise HTTPException(status_code=404, detail="Scan not found")
        if scan.status != "pending":
            raise HTTPException(status_code=400, detail=f"Scan already {scan.status}")

        case = CaseRepository.get_by_id(db, confirm_in.case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        # IMPORTANT: the date/time confirmed here is what's WRITTEN ON THE
        # DOCUMENT — a Pakistan-local court time, not UTC. Interpret it as
        # local, then convert, the same way the rest of the notification
        # pipeline already treats hearing times.
        has_specific_time = confirm_in.hearing_time is not None
        local_naive = datetime.combine(
            confirm_in.hearing_date, confirm_in.hearing_time or dt_time(hour=0)
        )
        local_aware = local_naive.replace(tzinfo=_LOCAL_TZ)
        hearing_datetime = local_aware.astimezone(timezone.utc)

        hearing_in = HearingCreate(
            title=confirm_in.title or f"Hearing — {case.case_number}",
            hearing_datetime=hearing_datetime,
            has_specific_time=has_specific_time,
            notes=confirm_in.notes or "Scheduled from scanned court document.",
        )

        # Reuses everything: has_specific_time anchoring, notification
        # schedule computation — nothing about hearing creation is
        # duplicated here.
        hearing = HearingService.create_hearing(db, case.id, hearing_in, user_id)

        ScanRepository.mark_confirmed(db, scan, case.id, hearing.id)

        return hearing

    @staticmethod
    def discard_scan(db: Session, scan_id: UUID, user_id: UUID) -> ScanPublic:
        scan = ScanRepository.get_by_id(db, scan_id, user_id)
        if not scan:
            raise HTTPException(status_code=404, detail="Scan not found")
        scan = ScanRepository.mark_discarded(db, scan)
        return ScanPublic.model_validate(scan)