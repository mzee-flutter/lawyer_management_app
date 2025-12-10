from sqlalchemy import Column, String, ForeignKey, DateTime, func, Text, Numeric, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database.base import Base
import uuid



class Case(Base):
    __tablename__ = "cases"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    case_number = Column(String, unique=True, nullable=False)
    registration_date = Column(DateTime(timezone=True), nullable=False)
    court_name = Column(String, nullable=True)
    judge_name = Column(String, nullable=True)

    # NEW — text based party names
    first_party_name = Column(String, nullable=False)
    opposite_party_name = Column(String, nullable=False)

    # Reference tables
    court_category_id = Column(UUID(as_uuid=True), ForeignKey("court_categories.id"), nullable=False)
    case_type_id = Column(UUID(as_uuid=True), ForeignKey("case_types.id"), nullable=False)
    case_stage_id = Column(UUID(as_uuid=True), ForeignKey("case_stages.id"), nullable=False)
    case_status_id = Column(UUID(as_uuid=True), ForeignKey("case_statuses.id"), nullable=False)

    case_notes = Column(Text, nullable=True)
    related_files = Column(JSON, nullable=True)
    legal_fees = Column(Numeric(10, 2), nullable=True)

    status = Column(String, nullable=False, default="active")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    archived_at = Column(DateTime(timezone=True), nullable=True)

    # Relationship: related clients
    related_clients = relationship(
        "CaseRelatedClient",
        back_populates="case",
        cascade="all, delete-orphan"
    )

    # Relationship: uploaded files
    files = relationship(
        "CaseFile",
        backref="case",
        cascade="all, delete-orphan"
    )

    court_category = relationship("CourtCategory")
    case_type = relationship("CaseType")
    case_stage = relationship("CaseStage")
    case_status = relationship("CaseStatus")

    



# Attachment table for other related people
class CaseRelatedClient(Base):
    __tablename__ = "case_related_clients"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False)
    client_id = Column(UUID(as_uuid=True), ForeignKey("client.id", ondelete="SET NULL"), nullable= True)

    role = Column(String, nullable=True)

    client = relationship("Client")
    case = relationship("Case", back_populates="related_clients")



# Reference Tables
class CourtCategory(Base):
    __tablename__ = "court_categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, unique=True, nullable=False)
    parent_id = Column(UUID(as_uuid=True), ForeignKey("court_categories.id"), nullable=True)

    parent = relationship("CourtCategory", remote_side=[id], backref="subcategories")



class CaseType(Base):
    __tablename__ = "case_types"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, unique=True, nullable=False)


class CaseStage(Base):
    __tablename__ = "case_stages"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, unique=True, nullable=False)


class CaseStatus(Base):
    __tablename__ = "case_statuses"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, unique=True, nullable=False)


class CaseFile(Base):
    __tablename__ = "case_files"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id", ondelete="CASCADE"))
    filename = Column(String, nullable=False)
    file_url = Column(String, nullable=False)
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    
