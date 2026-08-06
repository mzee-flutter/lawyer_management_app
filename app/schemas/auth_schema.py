from pydantic import BaseModel, EmailStr, Field, StringConstraints, field_validator
from typing import Annotated
from datetime import datetime
from uuid import UUID




class UserPublic(BaseModel):
    id:UUID
    name:str
    email:EmailStr
    role: str
    is_active:bool
    class Config:
        from_attributes= True


class FCMTokenRequest(BaseModel):
    fcm_token: str


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
    expire_at:int


class TokenRefresh(BaseModel):
    refresh_token:str

class AuthResponse(BaseModel):
    user:UserPublic
    tokens:TokenResponse
    class Config:
        from_attributes= True


# ---- Forgot password / reset / change password ----

class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: Annotated[str, StringConstraints(min_length=6, max_length=6, pattern=r"^\d{6}$")]


class VerifyOtpResponse(BaseModel):
    reset_token: str
    expires_in: int  # seconds


class ResetPasswordRequest(BaseModel):
    reset_token: str
    new_password: Annotated[str, StringConstraints(min_length=6)]


class ChangePasswordRequest(BaseModel):
    current_password: Annotated[str, StringConstraints(min_length=6)]
    new_password: Annotated[str, StringConstraints(min_length=6)]


class MessageResponse(BaseModel):
    message: str


class ChangePasswordResponse(BaseModel):
    message: str
    tokens: TokenResponse




# ---- Delete account ----
 
class DeleteAccountRequest(BaseModel):
    password: str
    confirmation: str
 
    # Defense in depth -- the Flutter screen already requires typing DELETE,
    # but a direct API call (or a modified client) could skip that. This
    # rejects the request with a clean 422 if the exact text isn't sent.
    @field_validator("confirmation")
    @classmethod
    def confirmation_must_match(cls, v: str) -> str:
        if v != "DELETE":
            raise ValueError('You must type "DELETE" exactly to confirm account deletion')
        return v