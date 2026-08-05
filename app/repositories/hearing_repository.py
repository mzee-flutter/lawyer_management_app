from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.models.case_model import Hearing, Case, CaseStage
from uuid import UUID


#---------------------------------------------------#
class HearingRepository:

    @staticmethod
    def create(db: Session, hearing_data: dict) -> Hearing:
        hearing = Hearing(
            **hearing_data,
            status="scheduled",
            created_at=datetime.now(timezone.utc),   
        )
        db.add(hearing)
        db.commit()
        db.refresh(hearing)
        return hearing

    @staticmethod
    def get_by_id(db: Session, hearing_id: UUID, user_id: UUID) -> Hearing | None:
        return db.query(Hearing).filter(
            Hearing.id == hearing_id,
            Hearing.user_id== user_id
        ).first()

    @staticmethod
    def get_all_by_case(db: Session, case_id: UUID, user_id: UUID) -> list[Hearing]:
        return (
            db.query(Hearing)
            .filter(
                Hearing.case_id == case_id,
                Hearing.user_id==user_id
            )
            .order_by(Hearing.hearing_datetime.asc())
            .all()
        )

    @staticmethod
    def delete(db: Session, hearing: Hearing):
        db.delete(hearing)
        db.commit()

    
    @staticmethod
    def get_hearings_with_cases_in_date_range(
        db: Session, 
        start_datetime: datetime, 
        end_datetime: datetime,
        user_id:UUID
    ) -> list[tuple[Hearing, Case]]:
        
        return (
            db.query(Hearing, Case, CaseStage)
            .join(Case, Hearing.case_id == Case.id)
            .join(CaseStage, Case.case_stage_id == CaseStage.id)
            .filter(Hearing.user_id==user_id)
            .filter(Hearing.hearing_datetime >= start_datetime)
            .filter(Hearing.hearing_datetime < end_datetime)
            .filter(Hearing.status != "cancelled")
            .filter(Hearing.status != "adjourned")
            .order_by(Hearing.hearing_datetime.asc())
            .all()
        )


    @staticmethod
    def get_upcoming_deadlines_with_cases(
        db:Session,
        start_datetime: datetime,
        end_datetime: datetime,
        user_id: UUID
    )-> list[tuple[Hearing, Case]]:
        
        return (
            db.query(Hearing, Case, CaseStage)
            .join(Case, Hearing.case_id==Case.id)
            .join(CaseStage, Case.case_stage_id == CaseStage.id)
            .filter(Hearing.user_id==user_id)
            .filter(Hearing.hearing_datetime >= start_datetime)
            .filter(Hearing.hearing_datetime < end_datetime)
            .filter(Hearing.status=="scheduled")
            .order_by(Hearing.hearing_datetime.asc())
            .all()
        )
    
    @staticmethod
    def get_hearings_for_month(
        db: Session,
        start_datetime: datetime,   # first second of the month (UTC)
        end_datetime: datetime,     # first second of next month (UTC)
        user_id: UUID,              # scope to the logged-in lawyer
    ) -> list[tuple]:               # list[tuple[Hearing, Case, CaseStage]]
        """
        Fetches ALL hearings (any status) for a calendar month.
        The service layer groups them by date and computes conflicts.
        
        We include all statuses so the calendar can show:
          - blue  → scheduled
          - amber → adjourned
          - red   → conflict
          - grey  → cancelled/completed
        """
        return (
            db.query(Hearing, Case, CaseStage)
            .join(Case, Hearing.case_id == Case.id)
            .join(CaseStage, Case.case_stage_id == CaseStage.id)
            .filter(Hearing.user_id == user_id)
            .filter(Hearing.hearing_datetime >= start_datetime)
            .filter(Hearing.hearing_datetime < end_datetime)
            # Include ALL statuses — calendar must show adjourned/cancelled too
            .order_by(Hearing.hearing_datetime.asc())
            .all()
        )
 
    @staticmethod
    def get_adjournments_by_case(
        db: Session,
        case_id: UUID,
        user_id: UUID
    ) -> list[tuple]:               # list[tuple[Hearing, Case]]
        """
        Returns all adjourned hearings for a specific case,
        ordered from most recent to oldest.
        Used for the adjournment history panel in the calendar.
        """
        return (
            db.query(Hearing, Case)
            .join(Case, Hearing.case_id == Case.id)
            .filter(Hearing.case_id == case_id)
            .filter(Hearing.user_id==user_id)
            .filter(Hearing.status == "adjourned")
            .order_by(Hearing.hearing_datetime.desc())
            .all()
        )