from pydantic import BaseModel, EmailStr, StringConstraints
from typing import Optional, Annotated
from datetime import datetime
import uuid

# ---- Shared Base ----
class ClientBase(BaseModel):
    name: Annotated[str, StringConstraints(min_length=1, max_length=255)]=None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    cnic: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None


# ---- Create ----
class ClientCreate(ClientBase):
    pass


# ---- Update (all fields optional) ----
class ClientUpdate(BaseModel):
    name: Optional[Annotated[str, StringConstraints(min_length=1, max_length= 255)]] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    cnic: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None


# ---- Public (Response Model) ----
class ClientPublic(ClientBase):
    id: uuid.UUID
    created_at: datetime
    updated_at: Optional[datetime] = None
    archived_at: Optional[datetime] = None

    class Config:
        from_attributes = True  # allows ORM -> Pydantic conversion
