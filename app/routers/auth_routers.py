from sqlalchemy.orm import Session
from fastapi import APIRouter,Depends, HTTPException,status
from app.database.session import get_db
from fastapi.security import OAuth2PasswordBearer
from app.schemas.auth_schema import AuthResponse
from app.schemas import auth_schema 
from app.models.auth_model import User
from app.services import auth_service
from app.services.auth_service import (
    register_user,
    login_user,
    get_current_user,
    generate_tokens,
    refresh_access_token,
    revoke_refresh,

)


router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(user: auth_schema.UserCreate, db: Session = Depends(get_db)) -> AuthResponse:
    return auth_service.register_user(db=db, user=user)


@router.post("/login", response_model=AuthResponse)
def login(user: auth_schema.UserLogin, db: Session = Depends(get_db)) -> AuthResponse:
    return auth_service.login_user(db=db, user=user)



@router.post("/refresh", response_model=auth_schema.TokenResponse)
def refresh(body:auth_schema.TokenRefresh, db:Session= Depends(get_db)):
    return auth_service.refresh_access_token(db, body.refresh_token)

@router.delete("/logout")
def logout(body:auth_schema.TokenRefresh, db:Session= Depends(get_db)):
    return auth_service.revoke_refresh(db=db, raw_refresh= body.refresh_token)



@router.get("/me", response_model=auth_schema.UserPublic)
def get_me(current_user:User= Depends(get_current_user)):
    return current_user


