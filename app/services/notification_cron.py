from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.database.session import SessionLocal
from app.models.case_model import Hearing, Case
from app.models.auth_model import User
from app.services.notification_services import send_hearing_notification


def process_hearing_notifications():
    print(f"[CRON] Running at {datetime.now(timezone.utc)}")
    db: Session = SessionLocal()
    try:
        now = datetime.now(timezone.utc)
 
        results = (
            db.query(Hearing, Case, User)
            .join(Case, Hearing.case_id == Case.id)
            .join(User, Hearing.user_id == User.id)
            .filter(Hearing.hearing_datetime > now)
            .filter(Hearing.status == "scheduled")  # skip adjourned/cancelled hearings
            .all()
        )

        for hearing, case, user in results:
            if not user or not user.fcm_token:
                continue

            court_name = case.court_name
            judge_name = case.judge_name

            if (
                hearing.notify_2_hour_at
                and not hearing.notify_2_hour_sent
                and now >= hearing.notify_2_hour_at
            ):
                send_hearing_notification(
                    token=user.fcm_token,
                    title="⏰ Hearing in 2 Hours",
                    body=(
                        f"Hearing: {hearing.title}\n"
                        f"Court: {court_name}\n"
                        f"Judge: {judge_name}"
                    ),
                    data={
                        "hearing_id": str(hearing.id),
                        "case_id": str(case.id),
                        "type": "2_hour_before",
                        "notification_id": f"{hearing.id}_2_hour",
                    },
                )
                hearing.notify_2_hour_sent = True
                db.commit()
                continue

            if (
                hearing.notify_1_day_at
                and not hearing.notify_1_day_sent
                and now >= hearing.notify_1_day_at
            ):
                send_hearing_notification(
                    token=user.fcm_token,
                    title="⚖️ Hearing Tomorrow",
                    body=(
                        f"Hearing: {hearing.title}\n"
                        f"Court: {court_name}\n"
                        f"Judge: {judge_name}"
                    ),
                    data={
                        "hearing_id": str(hearing.id),
                        "case_id": str(case.id),
                        "type": "1_day_before",
                        "notification_id": f"{hearing.id}_1_day",
                    },
                )
                hearing.notify_1_day_sent = True
                db.commit()

    except Exception:
        db.rollback()
        raise
    finally:
        db.close()