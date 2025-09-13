from pydantic import BaseModel, EmailStr, Field, StringConstraints
from typing import Annotated
from datetime import datetime




class UserPublic(BaseModel):
    id:int
    name:str
    email:EmailStr
    role: str
    is_active:bool
    class Config:
        from_attributes= True


class UserCreate(BaseModel):
    name:str
    email:EmailStr
    password: Annotated[str, StringConstraints(min_length= 6)]
        
class UserLogin(BaseModel):
    email:EmailStr
    password:Annotated[str, StringConstraints(min_length=6)]



class TokenResponse(BaseModel):
    access_token: str
    token_type:str=  Field(default="bearer")
    refresh_token:str
    expire_at:datetime


class TokenRefresh(BaseModel):
    refresh_token:str