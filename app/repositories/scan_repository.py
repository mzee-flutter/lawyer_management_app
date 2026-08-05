from datetime import datetime, timezone
from sqlalchemy.orm import Session
from uuid import UUID
from app.models.scan_model import ScannedDocument


class ScanRepository:

    @staticmethod
    def create(db: Session, data: dict) -> ScannedDocument:
        scan = ScannedDocument(**data)
        db.add(scan)
        db.commit()
        db.refresh(scan)
        return scan

    @staticmethod
    def get_by_id(db: Session, scan_id: UUID, user_id: UUID) -> ScannedDocument | None:
        return db.query(ScannedDocument).filter(
            ScannedDocument.id == scan_id,
            ScannedDocument.user_id == user_id
        ).first()

    @staticmethod
    def mark_confirmed(db: Session, scan: ScannedDocument, case_id: UUID, hearing_id: UUID) -> ScannedDocument:
        scan.case_id = case_id
        scan.hearing_id = hearing_id
        scan.status = "confirmed"
        scan.confirmed_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(scan)
        return scan

    @staticmethod
    def mark_discarded(db: Session, scan: ScannedDocument) -> ScannedDocument:
        scan.status = "discarded"
        db.commit()
        db.refresh(scan)
        return scan