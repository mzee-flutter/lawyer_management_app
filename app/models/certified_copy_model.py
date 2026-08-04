# models/certified_copy.py
#
# New table — add to your Alembic migration or create manually.
# Follows the exact same conventions as your Hearing model:
#   - UUID primary key
#   - user_id FK for multi-tenant scoping
#   - case_id FK with CASCADE delete
#   - server_default timestamps

import uuid
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.database.base import Base


class CertifiedCopyStatus(str, enum.Enum):
    applied    = "applied"
    processing = "processing"
    ready      = "ready"


class CertifiedCopy(Base):
    __tablename__ = "certified_copies"

    id = Column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id = Column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    case_id = Column(
        UUID(as_uuid=True),
        ForeignKey("cases.id", ondelete="CASCADE"),
        nullable=False,
    )

    # The court-issued reference number the lawyer writes on the slip
    # e.g. "CC-2026-0412"
    reference_number = Column(String, nullable=False)

    # Optional free-text description
    # e.g. "Order sheet dated 15 June 2026"
    description = Column(Text, nullable=True)

    # 3-stage state machine
    status = Column(
        SAEnum(CertifiedCopyStatus),
        default=CertifiedCopyStatus.applied,
        nullable=False,
    )

    # Stage timestamps — nullable until that stage is reached
    applied_at    = Column(DateTime(timezone=True), nullable=True)
    processing_at = Column(DateTime(timezone=True), nullable=True)
    ready_at      = Column(DateTime(timezone=True), nullable=True)

    # Standard audit fields — same as your Hearing model
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    case = relationship("Case", back_populates="certified_copies")
    user = relationship("User", back_populates="certified_copies")


# ─────────────────────────────────────────────────────────────────
# Add to your Case model:
#   certified_copies = relationship(
#       "CertifiedCopy",
#       back_populates="case",
#       cascade="all, delete-orphan"
#   )
#
# Add to your User model:
#   certified_copies = relationship("CertifiedCopy", back_populates="user")
# ─────────────────────────────────────────────────────────────────