from sqlalchemy import Column, String, ForeignKey, DateTime, func, Text, Numeric, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database.base import Base
import uuid


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

    # ✅ Client relations
    first_party_id = Column(UUID(as_uuid=True), ForeignKey("client.id"), nullable=False)
    second_party_id= Column(UUID(as_uuid=True), ForeignKey("client.id"), nullable= False)
    opposite_party_name = Column(String, nullable=True)

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

    # ✅ Relationships
    first_party = relationship("Client", back_populates="cases", foreign_keys=[first_party_id])
    second_party= relationship("Client", back_populates="cases", foreign_keys=[second_party_id])
    court_category = relationship("CourtCategory")
    case_type = relationship("CaseType")
    case_stage = relationship("CaseStage")
    case_status = relationship("CaseStatus")
    files = relationship("CaseFile", backref="case", cascade="all, delete-orphan")



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
    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id"), nullable=False)
    filename = Column(String, nullable=False)
    file_url = Column(String, nullable=False)
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    
