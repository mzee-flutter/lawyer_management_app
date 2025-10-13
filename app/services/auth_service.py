from sqlalchemy.orm import Session
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from datetime import datetime, timezone, timedelta, UTC
import os
from uuid import UUID

from app.database.session import get_db
from app.repositories import auth_repository
from app.schemas.auth_schema import UserPublic, UserCreate, UserLogin, TokenResponse, AuthResponse
from app.utils.auth_utils import hash_password, verify_password, _sha256, create_access_token, create_refresh_token, decode_accesss_token


auth2_scheme= OAuth2PasswordBearer(tokenUrl="/auth/login")



def register_user(db: Session, user: UserCreate)-> AuthResponse:
    db_user = auth_repository.get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User already exist")

    hashed_password = hash_password(user.password)
    new_user = auth_repository.create_user(db, user.name, user.email, hashed_password)
    tokens = generate_tokens(db, new_user)
    return {"user": new_user, "tokens": tokens}


def login_user(db: Session, user: UserLogin)->AuthResponse:
    db_user = auth_repository.get_user_by_email(db, user.email)
    if not db_user or not verify_password(user.password, db_user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")

    tokens = generate_tokens(db, db_user)
    return {"user": db_user, "tokens": tokens}




def get_current_user( db:Session=Depends(get_db), token:str= Depends(auth2_scheme)):
    payload= decode_accesss_token(token)

    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid or expired token",
                            headers={"WWW-Authenticate": "Bearer"})
    user= auth_repository.get_user_by_id(db, UUID(payload["sub"]))
    if not user:
        raise HTTPException(detail="Current User Not Found")
    return user


def generate_tokens(db:Session, user):
    payload= {"sub": str(user.id)}

    access_token, expire_in= create_access_token(payload)
    raw_refresh, hash_refresh= create_refresh_token()

    refresh_expire_at= datetime.now(UTC) + timedelta(days=int(os.getenv("REFRESH_TOKEN_EXPIRY_DAY")))

    auth_repository.save_refresh_token(db, user.id, hash_refresh, refresh_expire_at)
    expire_at_unix= int(expire_in.timestamp())
    tokens= TokenResponse(access_token=access_token, refresh_token=raw_refresh, expire_at= expire_at_unix)
    return tokens

    
def refresh_access_token(db:Session, raw_refresh:str):
    hash_refresh= _sha256(raw_refresh)
    record= auth_repository.get_refresh_token(db, hash_refresh)

    if not record or record.revoked or record.expire_at <= datetime.now(UTC):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or Expired token")
    
    user= record.user
    auth_repository.revoke_refresh_token(db, record)

    payload= {"sub":str(user.id)}
    access_token, expire_in= create_access_token(payload)

    raw_refresh, hash_refresh= create_refresh_token()
    refresh_expire_at= datetime.now(UTC) + timedelta(days=int(os.getenv("REFRESH_TOKEN_EXPIRY_DAY")))

    auth_repository.save_refresh_token(db, user.id, hash_refresh, refresh_expire_at)
    tokens= TokenResponse(access_token=access_token, refresh_token=raw_refresh, expire_at=expire_in)
    return tokens



def revoke_refresh(db:Session, raw_refresh:str):
    hash_refresh= _sha256(raw_refresh)
    record= auth_repository.get_refresh_token(db, hash_refresh)

    if not record:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

    if record.revoked:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token already expired")
    
    auth_repository.revoke_refresh_token(db, record)
    return {"message": "The user is logout Successfully"}
