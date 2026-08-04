from sqlalchemy import Column, String, Text, DateTime, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from app.database.base import Base
import uuid


class ScannedDocument(Base):
    """
    Audit trail + working record for the "Scan Court Document" feature.

    Lifecycle:
      pending    -> created right after the vision extraction call returns,
                    before the lawyer has reviewed anything.
      confirmed  -> lawyer reviewed the extracted fields and a Hearing was
                    created from them. hearing_id and case_id are set.
      discarded  -> lawyer reviewed and chose not to schedule anything from
                    this scan (bad photo, wrong document, etc.).

    Extracted fields are kept verbatim from the model output, even after the
    lawyer edits them on the confirmation screen — this is the audit trail
    that answers "where did this hearing date come from" later.
    """
    __tablename__ = "scanned_documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Set once the lawyer confirms which case this scan belongs to.
    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="SET NULL"), nullable=True)
    hearing_id = Column(UUID(as_uuid=True), ForeignKey("hearings.id", ondelete="SET NULL"), nullable=True)

    image_url = Column(String, nullable=False)

    extracted_case_number = Column(String, nullable=True)
    extracted_case_title = Column(String, nullable=True)
    extracted_court_name = Column(String, nullable=True)
    extracted_judge_name = Column(String, nullable=True)
    extracted_hearing_date = Column(String, nullable=True)   # raw "YYYY-MM-DD" from the model
    extracted_hearing_time = Column(String, nullable=True)   # raw "HH:MM", nullable
    extraction_confidence = Column(String, nullable=False, default="low")
    raw_model_text = Column(Text, nullable=True)

    match_status = Column(String, nullable=False, default="unmatched")  # matched | ambiguous | unmatched
    status = Column(String, nullable=False, default="pending")          # pending | confirmed | discarded

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    confirmed_at = Column(DateTime(timezone=True), nullable=True)