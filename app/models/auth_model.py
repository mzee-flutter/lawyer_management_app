from sqlalchemy import Column,String, Integer, Boolean, DateTime, ForeignKey, func
from app.database.base import Base
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid




class User(Base):
    __tablename__ = "users"

    id =Column(UUID( as_uuid = True), primary_key=True, default=uuid.uuid4)
    name =  Column(String, index=True )
    email= Column(String, unique=True, nullable=False, index=True)
    password_hash= Column(String, nullable=False)
    role= Column(String, default="user")
    is_active= Column(Boolean, default=True)
    created_at= Column(DateTime(timezone=True), server_default=func.now())

    refresh_tokens= relationship("RefreshToken", back_populates="user", cascade= "all, delete-orphan")


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id= Column(String, primary_key=True, default=lambda:str(uuid.uuid4()))
    user_id= Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE",))
    token_hash= Column(String(128), unique=True, nullable=False,  index=True)
    revoked= Column(Boolean, default=False)
    expire_at= Column(DateTime(timezone=True), nullable=False)
    created_at= Column(DateTime(timezone=True), server_default=func.now())

    user= relationship("User", back_populates="refresh_tokens")



#the user and refresh_tokens are refer to each other like for one user there is multiple refresh-tokens
#but for every refresh-token there is only one user(one to many and many to one relationship)