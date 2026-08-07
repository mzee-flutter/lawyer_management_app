from datetime import timedelta, timezone, datetime

from app.core.notification_settings import (
    HEARING_DAY_BEFORE_MINUTES,
    HEARING_HOUR_BEFORE_MINUTES,
)


def compute_hearing_notification_schedule(hearing) -> None:
    if hearing.hearing_datetime is None:
        hearing.notify_1_day_at = None
        hearing.notify_2_hour_at = None
        hearing.notify_1_day_sent = False
        hearing.notify_2_hour_sent = False
        return

    base = hearing.hearing_datetime
    if base.tzinfo is None:
        base = base.replace(tzinfo=timezone.utc)

    now = datetime.now(timezone.utc)
    if base <= now:
        # Already in the past (retroactively logged hearing, or a
        # misconfigured anchor) — no notification makes sense.
        hearing.notify_1_day_at = None
        hearing.notify_2_hour_at = None
        hearing.notify_1_day_sent = False
        hearing.notify_2_hour_sent = False
        return

    hearing.notify_1_day_at = base - timedelta(minutes=HEARING_DAY_BEFORE_MINUTES)
    hearing.notify_2_hour_at = base - timedelta(minutes=HEARING_HOUR_BEFORE_MINUTES)
    hearing.notify_1_day_sent = False
    hearing.notify_2_hour_sent = False