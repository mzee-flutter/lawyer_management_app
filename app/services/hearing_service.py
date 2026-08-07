from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone, date
from uuid import UUID
from app.models.auth_model import User
from fastapi import HTTPException
from calendar import monthrange
from collections import defaultdict
from datetime import datetime, timedelta, timezone, time as dt_time
from zoneinfo import ZoneInfo
from app.core.notification_settings import DEFAULT_HEARING_HOUR_LOCAL, APP_LOCAL_TIMEZONE

from app.schemas.hearing_schema import( 
    HearingCreate, 
    HearingPublic,
    HearingUpdate, 
    TodayHearingResponse
)

from app.repositories.case_repository import CaseRepository
from app.repositories.hearing_repository import HearingRepository

from app.schemas.hearing_schema import (
    CalendarDayResponse,
    CalendarHearingItem, 
    CalendarMonthResponse, 
    AdjournmentHistoryResponse,
    AdjournmentEntry
) 
from app.services.hearing_notification_service import compute_hearing_notification_schedule




# ---------------------------------------------------
# Case Hearings Service
# ---------------------------------------------------
GRACE_PERIOD= timedelta(minutes=1)
# Conflict window: two hearings within this many minutes = conflict
_CONFLICT_WINDOW_MINUTES = 60
# Add alongside your existing _CONFLICT_WINDOW_MINUTES constant.
_SOFT_CONFLICT_HEARING_THRESHOLD = 3

def is_past_hearing_date(hearing_dt: datetime) -> bool:
    today = datetime.now(timezone.utc).date()
    return hearing_dt.date() < today

_LOCAL_TZ = ZoneInfo(APP_LOCAL_TIMEZONE)

class HearingService:

    @staticmethod
    def create_hearing(
        db: Session, case_id: UUID,
        hearing_in: HearingCreate,
        user_id: UUID
    ) -> HearingPublic:

        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        if case.archived_at is not None:
            raise HTTPException(status_code=400, detail="Cannot add hearing to archived case")

        hearing_data = hearing_in.model_dump()

        hearing_datetime = hearing_data.get("hearing_datetime")
        if hearing_datetime is not None and hearing_datetime.tzinfo is None:
            hearing_datetime = hearing_datetime.replace(tzinfo=timezone.utc)

        has_specific_time = hearing_data.get("has_specific_time", False)

        if hearing_datetime is not None and not has_specific_time:
        # Date-only hearing — discard whatever arbitrary time-of-day the
        # client sent and anchor to a fixed, consistent local court time.
            local_date = hearing_datetime.astimezone(_LOCAL_TZ).date()
            anchored_local = datetime.combine(
                local_date, dt_time(hour=DEFAULT_HEARING_HOUR_LOCAL), tzinfo=_LOCAL_TZ
            )
            hearing_datetime = anchored_local.astimezone(timezone.utc)

        hearing_data["hearing_datetime"] = hearing_datetime
        hearing_data["user_id"] = user_id
        hearing_data["case_id"] = case_id

        hearing = HearingRepository.create(db, hearing_data)

        compute_hearing_notification_schedule(hearing)
        db.commit()
        db.refresh(hearing)

        return HearingPublic.model_validate(hearing)


    @staticmethod
    def update_hearing(
        db: Session,
        hearing_id: UUID,
        hearing_in: HearingUpdate,
        user_id: UUID
    ) -> HearingPublic:

        hearing = HearingRepository.get_by_id(db, hearing_id, user_id)
        if not hearing:
            raise HTTPException(status_code=404, detail="Hearing not found")

        update_data = hearing_in.model_dump(exclude_unset=True)

        hearing_datetime_updated = "hearing_datetime" in update_data
        has_specific_time_updated = "has_specific_time" in update_data
        status_changing_to = update_data.get("status")

        # Same defensive UTC-tagging as create, in case a naive datetime arrives.
        if hearing_datetime_updated and update_data["hearing_datetime"] is not None:
            dt = update_data["hearing_datetime"]
            if dt.tzinfo is None:
                update_data["hearing_datetime"] = dt.replace(tzinfo=timezone.utc)

        # ── Apply all field updates ──────────────────────────────
        for field, value in update_data.items():
            setattr(hearing, field, value)

        # ── Anchor to the fixed default local time whenever this hearing
        # doesn't have a specific time — covers three cases in one place:
        #   (a) hearing_datetime changed and has_specific_time is/was false
        #   (b) has_specific_time toggled off, keeping the same date
        #   (c) has_specific_time toggled on — no anchoring, real time is used
        if (hearing_datetime_updated or has_specific_time_updated) and hearing.hearing_datetime is not None:
            if not hearing.has_specific_time:
                local_date = hearing.hearing_datetime.astimezone(_LOCAL_TZ).date()
                anchored_local = datetime.combine(
                    local_date, dt_time(hour=DEFAULT_HEARING_HOUR_LOCAL), tzinfo=_LOCAL_TZ
                )
                hearing.hearing_datetime = anchored_local.astimezone(timezone.utc)

        # ── Notification recompute when datetime (or its anchor) changes ─
        if hearing_datetime_updated or has_specific_time_updated:
            compute_hearing_notification_schedule(hearing)

        # ── Auto-stamp adjournment_date when adjourning ──────────
        if status_changing_to == "adjourned":
            if not hearing.adjournment_date:
                hearing.adjournment_date = datetime.now(timezone.utc).date()

        # ── Clear adjournment data if un-adjourning ───────────────
        if status_changing_to in {"scheduled", "completed", "cancelled"}:
            if "adjournment_reason" not in update_data:
                hearing.adjournment_reason = None
            if "adjournment_date" not in update_data:
                hearing.adjournment_date = None

        hearing.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(hearing)

        return HearingPublic.model_validate(hearing)


    @staticmethod
    def get_hearings_by_case(
        db: Session,
        case_id: UUID,
        user_id: UUID
    ) -> list[HearingPublic]:

        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        hearings = HearingRepository.get_all_by_case(db, case_id, user_id)

        return [HearingPublic.model_validate(h) for h in hearings]
        



    @staticmethod
    def get_hearing(
        db: Session,
        hearing_id: UUID,
        user_id: UUID
    ) -> HearingPublic:

        hearing = HearingRepository.get_by_id(db, hearing_id, user_id)
        if not hearing:
            raise HTTPException(status_code=404, detail="Hearing not found")

        return HearingPublic.model_validate(hearing)



    @staticmethod
    def delete_hearing(
        db: Session,
        hearing_id: UUID,
        user_id: UUID
    ) -> HearingPublic:

        hearing = HearingRepository.get_by_id(db, hearing_id, user_id)
        if not hearing:
            raise HTTPException(status_code=404, detail="Hearing not found")

        hearing_copy = HearingPublic.model_validate(hearing)

        HearingRepository.delete(db, hearing)

        return hearing_copy

   


    @staticmethod
    def get_today_hearings(
        db: Session, 
        utc_offset_hours: int,
        user_id: UUID
    ) -> list[TodayHearingResponse]:

        tz_offset = timedelta(hours=utc_offset_hours)
        now_local = datetime.now(timezone.utc) + tz_offset
        
        today_start = datetime(
            now_local.year, now_local.month, now_local.day,
            0, 0, 0, tzinfo=timezone.utc
        ) - tz_offset
        today_end = today_start + timedelta(days=1)
        today_date = now_local.date()

        raw_records = HearingRepository.get_hearings_with_cases_in_date_range(
            db=db, 
            start_datetime=today_start, 
            end_datetime=today_end,
            user_id=user_id
        )

        # Every record here is on the same local day (today) by construction
        # of the date-range query, so classify once and stamp the same result
        # onto every hearing returned.
        has_hard, has_soft, _ = _classify_day(
            [hearing for hearing, case, caseStage in raw_records]
        )
        conflict_level = "hard" if has_hard else "soft" if has_soft else "none"

        return [
            TodayHearingResponse(
                id=str(hearing.id),
                case_id=str(hearing.case_id),
                title=hearing.title,
                hearing_datetime=hearing.hearing_datetime,
                has_specific_time=hearing.has_specific_time,
                conflict_level=conflict_level,
                notes=hearing.notes,
                status=hearing.status,
                created_at=hearing.created_at,
                updated_at=hearing.updated_at,
                court_name=case.court_name,
                judge_name=case.judge_name,
                first_party_name=case.first_party_name,
                opposite_party_name=case.opposite_party_name,
                case_stage_name=caseStage.name if caseStage else "No Stage",
                case_number=case.case_number,
                days_until_hearing=(hearing.hearing_datetime.date() - today_date).days,
            )
            for hearing, case, caseStage in raw_records
        ]


    @staticmethod
    def get_upcoming_deadlines(
        db: Session, 
        days_ahead: int, 
        utc_offset_hours: int,
        user_id: UUID
    ) -> list[TodayHearingResponse]:

        tz_offset = timedelta(hours=utc_offset_hours)
        now_local = datetime.now(timezone.utc) + tz_offset
        today_date = now_local.date()

        window_start = datetime.now(timezone.utc)
        window_end = window_start + timedelta(days=days_ahead)

        raw_records = HearingRepository.get_upcoming_deadlines_with_cases(
            db=db,
            start_datetime=window_start,
            end_datetime=window_end,
            user_id=user_id
        )

        # Group by local calendar date so each day is classified independently
        # — a hearing on the 24th shouldn't affect conflict status on the 28th.
        # Same grouping technique already used in get_calendar_month.
        hearings_by_date: dict[date, list] = defaultdict(list)
        for hearing, case, caseStage in raw_records:
            local_date = (hearing.hearing_datetime + tz_offset).date()
            hearings_by_date[local_date].append(hearing)

        conflict_level_by_date: dict[date, str] = {}
        for local_date, day_hearings in hearings_by_date.items():
            has_hard, has_soft, _ = _classify_day(day_hearings)
            conflict_level_by_date[local_date] = (
                "hard" if has_hard else "soft" if has_soft else "none"
            )

        return [
            TodayHearingResponse(
                id=str(hearing.id),
                case_id=str(hearing.case_id),
                title=hearing.title,
                hearing_datetime=hearing.hearing_datetime,
                has_specific_time=hearing.has_specific_time,
                conflict_level=conflict_level_by_date[
                    (hearing.hearing_datetime + tz_offset).date()
                ],
                notes=hearing.notes,
                status=hearing.status,
                created_at=hearing.created_at,
                updated_at=hearing.updated_at,
                court_name=case.court_name,
                judge_name=case.judge_name,
                first_party_name=case.first_party_name,
                opposite_party_name=case.opposite_party_name,
                case_stage_name=caseStage.name if caseStage else "No Stage",
                case_number=case.case_number,
                days_until_hearing=(hearing.hearing_datetime.date() - today_date).days,
            )
            for hearing, case, caseStage in raw_records
        ]


    @staticmethod
    def get_calendar_month(
        db: Session,
        year: int,
        month: int,
        utc_offset_hours: int,
        user_id: UUID,
    ) -> CalendarMonthResponse:

        if not (1 <= month <= 12):
            raise HTTPException(status_code=422, detail="month must be 1–12")
        if not (2000 <= year <= 2100):
            raise HTTPException(status_code=422, detail="year out of range")

        tz_offset = timedelta(hours=utc_offset_hours)

        local_month_start = datetime(year, month, 1, 0, 0, 0, tzinfo=timezone.utc)
        utc_start = local_month_start - tz_offset

        _, last_day = monthrange(year, month)
        local_month_end = datetime(year, month, last_day, 23, 59, 59, tzinfo=timezone.utc)
        utc_end = local_month_end - tz_offset + timedelta(seconds=1)

        raw_records = HearingRepository.get_hearings_for_month(
            db=db,
            start_datetime=utc_start,
            end_datetime=utc_end,
            user_id=user_id,
        )

        days_map: dict[date, list[tuple]] = defaultdict(list)
        for hearing, case, case_stage in raw_records:
            local_dt = hearing.hearing_datetime + tz_offset
            local_date = local_dt.date()
            days_map[local_date].append((hearing, case, case_stage))

        calendar_days: list[CalendarDayResponse] = []

        for day_date in sorted(days_map.keys()):
            day_records = days_map[day_date]

            hearing_items = [
                CalendarHearingItem(
                    id=str(hearing.id),
                    case_id=str(hearing.case_id),
                    title=hearing.title,
                    hearing_datetime=hearing.hearing_datetime,
                    has_specific_time=hearing.has_specific_time,
                    status=hearing.status,
                    notes=hearing.notes,
                    court_name=case.court_name,
                    judge_name=case.judge_name,
                    first_party_name=case.first_party_name,
                    opposite_party_name=case.opposite_party_name,
                    case_stage_name=case_stage.name if case_stage else "No Stage",
                    case_number=case.case_number,
                )
                for hearing, case, case_stage in day_records
            ]

            has_hard, has_soft, reasons = _classify_day(hearing_items)

            has_adjourned = any(
                h.status == "adjourned" for h in hearing_items
            )

            calendar_days.append(
                CalendarDayResponse(
                    date=day_date,
                    hearings=hearing_items,
                    has_conflict=has_hard,
                    has_soft_conflict=has_soft,
                    conflict_reasons=reasons,
                    has_adjourned=has_adjourned,
                    hearing_count=len(hearing_items),
                )
            )

        return CalendarMonthResponse(
            year=year,
            month=month,
            days=calendar_days,
        )
    
    @staticmethod
    def get_adjournment_history(
        db: Session,
        case_id: UUID,
        user_id: UUID
    ) -> AdjournmentHistoryResponse:

        case = CaseRepository.get_by_id(db, case_id, user_id)
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")

        raw_records = HearingRepository.get_adjournments_by_case(
            db=db,
            case_id=case_id,
            user_id=user_id
        )

        adjournment_entries = [
            AdjournmentEntry(
                id=str(hearing.id),
                case_id=str(hearing.case_id),
                title=hearing.title,
                adjournment_date=hearing.adjournment_date,
                adjournment_reason=hearing.adjournment_reason,
                hearing_datetime=hearing.hearing_datetime,
                rescheduled_to=None,
            )
            for hearing, case_obj in raw_records
        ]

        return AdjournmentHistoryResponse(
            case_id=str(case.id),
            case_number=case.case_number,
            first_party_name=case.first_party_name,
            opposite_party_name=case.opposite_party_name,
            total_adjournments=len(adjournment_entries),
            adjournments=adjournment_entries,
        )


# get_adjournment_history is untouched — no conflict logic involved there.
# Keep your existing implementation exactly as is.


def _classify_day(hearings) -> tuple[bool, bool, list[str]]:
    """
    Classifies a single day's hearings into hard/soft conflict status.
    Accepts either ORM Hearing rows or CalendarHearingItem instances —
    only .status, .has_specific_time, and .hearing_datetime are used, so
    both shapes work here without any adapting.

    Hard conflict: >=2 scheduled hearings, both with an explicit specific
    time, within _CONFLICT_WINDOW_MINUTES of each other. Unchanged rule —
    the lawyer is physically double-booked.

    Soft conflict (only evaluated when there's no hard conflict, so a day
    is never flagged as both at once): either
      - >=2 scheduled hearings and at least one lacks a specific time
        (can't yet confirm whether they actually clash), or
      - >=3 scheduled hearings that day regardless of timing (workload risk)

    Returns (has_hard, has_soft, reasons) — reasons is a short list of
    human-readable strings explaining why the day was flagged soft.
    """
    scheduled = [h for h in hearings if h.status.lower() == "scheduled"]

    timed = [h for h in scheduled if h.has_specific_time]
    timed_sorted = sorted(timed, key=lambda h: h.hearing_datetime)

    has_hard = False
    for i in range(len(timed_sorted) - 1):
        gap = (
            timed_sorted[i + 1].hearing_datetime
            - timed_sorted[i].hearing_datetime
        ).total_seconds() / 60
        if abs(gap) < _CONFLICT_WINDOW_MINUTES:
            has_hard = True
            break

    if has_hard:
        return True, False, []

    reasons: list[str] = []
    untimed_count = len(scheduled) - len(timed)

    if len(scheduled) >= 2 and untimed_count >= 1:
        reasons.append(
            f"{untimed_count} hearing{'s' if untimed_count != 1 else ''} "
            f"without a specific time"
        )

    if len(scheduled) >= _SOFT_CONFLICT_HEARING_THRESHOLD:
        reasons.append(f"{len(scheduled)} hearings scheduled the same day")

    has_soft = len(reasons) > 0
    return False, has_soft, reasons




#     @staticmethod
#     def get_today_hearings(
#         db: Session, 
#         utc_offset_hours: int,
#         user_id: UUID
#     ) -> list[TodayHearingResponse]:
    
#         # 1. Handle timezone offsets (Business Logic)
#         tz_offset = timedelta(hours=utc_offset_hours)
#         now_local = datetime.now(timezone.utc) + tz_offset
        
#         today_start = datetime(
#             now_local.year, now_local.month, now_local.day,
#             0, 0, 0, tzinfo=timezone.utc
#         ) - tz_offset
#         today_end = today_start + timedelta(days=1)
#         today_date = now_local.date()

#         # 2. Delegate data fetching to the Repository Layer
#         raw_records = HearingRepository.get_hearings_with_cases_in_date_range(
#             db=db, 
#             start_datetime=today_start, 
#             end_datetime=today_end,
#             user_id=user_id
#         )

#         # 3. Process, wire up, and serialize into Pydantic shapes
#         return [
#             TodayHearingResponse(
#                 id=str(hearing.id),
#                 case_id=str(hearing.case_id),
#                 title=hearing.title,
#                 hearing_datetime=hearing.hearing_datetime,
#                 notes=hearing.notes,
#                 status=hearing.status,
#                 created_at=hearing.created_at,
#                 updated_at=hearing.updated_at,
#                 court_name=case.court_name,
#                 judge_name=case.judge_name,
#                 first_party_name=case.first_party_name,
#                 opposite_party_name=case.opposite_party_name,
#                 case_stage_name=caseStage.name if caseStage else "No Stage",
#                 case_number=case.case_number,
#                 days_until_hearing=(hearing.hearing_datetime.date() - today_date).days,
#             )
#             for hearing, case, caseStage in raw_records
#         ]


#     @staticmethod
#     def get_upcoming_deadlines(
#         db: Session, 
#         days_ahead: int, 
#         utc_offset_hours: int,
#         user_id: UUID
#     ) -> list[TodayHearingResponse]:
       
#         tz_offset = timedelta(hours=utc_offset_hours)
#         now_local = datetime.now(timezone.utc) + tz_offset
#         today_date = now_local.date()

#         window_start = datetime.now(timezone.utc)
#         window_end = window_start + timedelta(days=days_ahead)

#         # 2. Extract database collection rows from the repository layer
#         raw_records = HearingRepository.get_upcoming_deadlines_with_cases(
#             db=db,
#             start_datetime=window_start,
#             end_datetime=window_end,
#             user_id=user_id
#         )

#         # 3. Process records and generate the computed metadata objects
#         return [
#             TodayHearingResponse(
#                 id=str(hearing.id),
#                 case_id=str(hearing.case_id),
#                 title=hearing.title,
#                 hearing_datetime=hearing.hearing_datetime,
#                 notes=hearing.notes,
#                 status=hearing.status,
#                 created_at=hearing.created_at,
#                 updated_at=hearing.updated_at,
#                 court_name=case.court_name,
#                 judge_name=case.judge_name,
#                 first_party_name=case.first_party_name,
#                 opposite_party_name=case.opposite_party_name,
#                 case_stage_name=caseStage.name if caseStage else "No Stage",
#                 case_number=case.case_number,
#                 days_until_hearing=(hearing.hearing_datetime.date() - today_date).days,
#             )
#             for hearing, case, caseStage in raw_records
#         ]
    


 

#     @staticmethod
#     def get_calendar_month(
#         db: Session,
#         year: int,
#         month: int,
#         utc_offset_hours: int,
#         user_id: UUID,
#     ) -> CalendarMonthResponse:
#         """
#         Returns all hearing days for a calendar month.
#         Business logic handled here:
#           - UTC window computation for the month
#           - Grouping hearings by local date
#           - Conflict detection (≥2 hearings within 60 min on same day)
#           - has_adjourned flag per day
#         """
 
#         # ── 1. Validate inputs ────────────────────────────────────
#         if not (1 <= month <= 12):
#             raise HTTPException(status_code=422, detail="month must be 1–12")
#         if not (2000 <= year <= 2100):
#             raise HTTPException(status_code=422, detail="year out of range")
 
#         # ── 2. Compute UTC window for the requested local month ───
#         tz_offset = timedelta(hours=utc_offset_hours)
 
#         # First moment of month in local time, converted to UTC
#         local_month_start = datetime(year, month, 1, 0, 0, 0, tzinfo=timezone.utc)
#         utc_start = local_month_start - tz_offset
 
#         # Last moment of month in local time, converted to UTC
#         _, last_day = monthrange(year, month)
#         local_month_end = datetime(year, month, last_day, 23, 59, 59, tzinfo=timezone.utc)
#         utc_end = local_month_end - tz_offset + timedelta(seconds=1)
 
#         # ── 3. Fetch raw data from repository ────────────────────
#         raw_records = HearingRepository.get_hearings_for_month(
#             db=db,
#             start_datetime=utc_start,
#             end_datetime=utc_end,
#             user_id=user_id,
#         )
 
#         # ── 4. Group hearings by local date ───────────────────────
#         # Convert UTC hearing_datetime to local date for grouping
#         days_map: dict[date, list[tuple]] = defaultdict(list)
#         for hearing, case, case_stage in raw_records:
#             local_dt = hearing.hearing_datetime + tz_offset
#             local_date = local_dt.date()
#             days_map[local_date].append((hearing, case, case_stage))
 
#         # ── 5. Build CalendarDayResponse for each day ─────────────
#         calendar_days: list[CalendarDayResponse] = []
 
#         for day_date in sorted(days_map.keys()):
#             day_records = days_map[day_date]
 
#             # Build hearing items
#             hearing_items = [
#                 CalendarHearingItem(
#                     id=str(hearing.id),
#                     case_id=str(hearing.case_id),
#                     title=hearing.title,
#                     hearing_datetime=hearing.hearing_datetime,
#                     status=hearing.status,
#                     notes=hearing.notes,
#                     court_name=case.court_name,
#                     judge_name=case.judge_name,
#                     first_party_name=case.first_party_name,
#                     opposite_party_name=case.opposite_party_name,
#                     case_stage_name=case_stage.name if case_stage else "No Stage",
#                     case_number=case.case_number,
#                 )
#                 for hearing, case, case_stage in day_records
#             ]
 
#             # Conflict detection:
#             # Two hearings conflict if they are both "scheduled"
#             # and their times are within _CONFLICT_WINDOW_MINUTES of each other
#             has_conflict = _detect_conflict(hearing_items)
 
#             # Adjourned flag: at least one hearing on this day is adjourned
#             has_adjourned = any(
#                 h.status == "adjourned" for h in hearing_items
#             )
 
#             calendar_days.append(
#                 CalendarDayResponse(
#                     date=day_date,
#                     hearings=hearing_items,
#                     has_conflict=has_conflict,
#                     has_adjourned=has_adjourned,
#                     hearing_count=len(hearing_items),
#                 )
#             )
 
#         return CalendarMonthResponse(
#             year=year,
#             month=month,
#             days=calendar_days,
#         )
 
#     @staticmethod
#     def get_adjournment_history(
#         db: Session,
#         case_id: UUID,
#         user_id: UUID
#     ) -> AdjournmentHistoryResponse:
       
#         # ── 1. Verify case exists ──────────────────────────────────
#         case = CaseRepository.get_by_id(db, case_id, user_id)
#         if not case:
#             raise HTTPException(status_code=404, detail="Case not found")
 
#         # ── 2. Fetch adjourned hearings ───────────────────────────
#         raw_records = HearingRepository.get_adjournments_by_case(
#             db=db,
#             case_id=case_id,
#             user_id=user_id
#         )
 
#         # ── 3. Build adjournment entries ──────────────────────────
#         adjournment_entries = [
#             AdjournmentEntry(
#                 id=str(hearing.id),
#                 case_id=str(hearing.case_id),
#                 title=hearing.title,
#                 adjournment_date=hearing.adjournment_date,
#                 adjournment_reason=hearing.adjournment_reason,
#                 hearing_datetime=hearing.hearing_datetime,
#                 rescheduled_to=None,  # Future: link to next scheduled hearing
#             )
#             for hearing, case_obj in raw_records
#         ]
 
#         return AdjournmentHistoryResponse(
#             case_id=str(case.id),
#             case_number=case.case_number,
#             first_party_name=case.first_party_name,
#             opposite_party_name=case.opposite_party_name,
#             total_adjournments=len(adjournment_entries),
#             adjournments=adjournment_entries,
#         )
 
 
# # ─────────────────────────────────────────────────────────────────
# # Private helper — conflict detection
# # Kept here (service layer) not in repository — it's business logic
# # ─────────────────────────────────────────────────────────────────
# def _detect_conflict(hearings: list[CalendarHearingItem]) -> bool:
#     """
#     Returns True if any two SCHEDULED hearings on the same day
#     have datetimes within _CONFLICT_WINDOW_MINUTES of each other.
#     Cancelled/adjourned/completed hearings are excluded from conflict check.
#     """
#     scheduled = [
#         h for h in hearings if h.status.lower() == "scheduled"
#     ]
#     if len(scheduled) < 2:
#         return False
 
#     # Already sorted by hearing_datetime from the repository query
#     for i in range(len(scheduled) - 1):
#         gap = (
#             scheduled[i + 1].hearing_datetime
#             - scheduled[i].hearing_datetime
#         ).total_seconds() / 60
#         if abs(gap) < _CONFLICT_WINDOW_MINUTES:
#             return True
 
#     return False