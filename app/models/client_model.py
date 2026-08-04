from sqlalchemy import Column, String, DateTime, func, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database.base import Base
import uuid

class Client(Base):
    __tablename__ = "client" 

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id= Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False, index=True)
    email = Column(String, index=True)  
    phone = Column(String, index=True)
    cnic = Column(String) 
    address = Column(String)
    notes = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    archived_at = Column(DateTime(timezone=True), nullable=True)

    
    cases = relationship(
        "CaseRelatedClient",
        back_populates="client",
    )
