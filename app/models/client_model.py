from sqlalchemy import Column, String, DateTime, func, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database.base import Base
import uuid

class Client(Base):
    __tablename__ = "client" 

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False, index=True)
    email = Column(String, index=True)  
    phone = Column(String, index=True)
    cnic = Column(String) 
    address = Column(String)
    notes = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    archived_at = Column(DateTime(timezone=True), nullable=True)

    
    # cases = relationship(
    #     "Case",
    #     back_populates="first_party",
    #     foreign_keys="[Case.first_party_id]"
    # )
    # tasks = relationship("Task", back_populates="client", cascade="all, delete-orphan")
    # documents = relationship("Document", back_populates="client", cascade="all, delete-orphan")
    # notes_rel = relationship("Note", back_populates="client", cascade="all, delete-orphan")
