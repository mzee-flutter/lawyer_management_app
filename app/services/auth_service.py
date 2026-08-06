from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from datetime import datetime, timedelta, UTC
import os
from uuid import UUID
from app.services.email_service import send_account_deleted_email

from app.database.session import get_db
from app.repositories import auth_repository
from app.repositories.auth_repository import (get_user_by_id, update_fcm_token)
from app.schemas.auth_schema import (
    UserPublic, UserCreate, UserLogin, TokenResponse, AuthResponse,
    ForgotPasswordRequest, VerifyOtpRequest, VerifyOtpResponse,
    ResetPasswordRequest, ChangePasswordRequest,DeleteAccountRequest
)
from app.utils.auth_utils import (
    hash_password, verify_password, _sha256, create_access_token,
    create_refresh_token, decode_accesss_token,
    generate_otp, create_password_reset_token, decode_password_reset_token,
)
from app.services.email_service import send_otp_email, send_password_changed_email


auth2_scheme= OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")



def register_user(db: Session, user: UserCreate)-> AuthResponse:
    db_user = auth_repository.get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User already exist")

    hashed_password = hash_password(user.password)
    new_user = auth_repository.create_user(db, user.name, user.email, hashed_password)
    tokens = generate_tokens(db, new_user)
    return {"user": new_user, "tokens": tokens}
   


def login_user(db: Session, user: UserLogin)->TokenResponse:
    db_user = auth_repository.get_user_by_email(db, user.email)
    if not db_user or not verify_password(user.password, db_user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")

    tokens = generate_tokens(db, db_user)
    return {"user": db_user, "tokens": tokens}
    
   
    
   
  

def get_current_user( db:Session=Depends(get_db), token:str= Depends(auth2_scheme)):
    payload= decode_accesss_token(token)

    # Reject missing/invalid tokens AND password-reset tokens explicitly --
    # a reset token must never be usable as a regular access token, even
    # though it's signed with the same secret.
    if not payload or payload.get("type") == "password_reset":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid or expired token",
                            headers={"WWW-Authenticate": "Bearer"})
    user= auth_repository.get_user_by_id(db, UUID(payload["sub"]))
    if not user:
        # NOTE: was previously `raise HTTPException(detail="Current User Not Found")`
        # -- status_code is required by FastAPI's HTTPException and this
        # would have thrown a raw TypeError at runtime instead of a 404.
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Current user not found")
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
    expire_timestamp= int(expire_in.timestamp())
    tokens= TokenResponse(access_token=access_token, refresh_token=raw_refresh, expire_at= expire_timestamp)
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


def save_user_fcm_token(
    db: Session,
    user_id: UUID,
    fcm_token: str,
):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    update_fcm_token(db, user, fcm_token)
    return {"message": "FCM token saved successfully"}


# ---- Forgot password / reset / change password ----

def forgot_password(db: Session, payload: ForgotPasswordRequest) -> dict:
    """
    Always returns the same generic message, whether or not the email is
    registered -- this prevents the endpoint from being used to enumerate
    valid accounts. Only does real work internally when the user exists.
    """
    generic_response = {"message": "If that email is registered, a reset code has been sent."}

    user = auth_repository.get_user_by_email(db, payload.email)
    if not user:
        return generic_response

    cooldown_seconds = int(os.getenv("OTP_RESEND_COOLDOWN_SECONDS", 60))
    last_request = auth_repository.get_last_otp_request_time(db, user.id)
    if last_request and (datetime.now(UTC) - last_request).total_seconds() < cooldown_seconds:
        # Silently no-op on rapid repeat requests instead of sending another
        # email or revealing the cooldown to the caller.
        return generic_response

    # Only one OTP should ever be valid at a time.
    auth_repository.invalidate_active_otps(db, user.id)

    otp = generate_otp()
    otp_expiry_minutes = int(os.getenv("OTP_EXPIRY_MIN", 10))
    expires_at = datetime.now(UTC) + timedelta(minutes=otp_expiry_minutes)
    auth_repository.create_password_reset_otp(db, user.id, _sha256(otp), expires_at)

    try:
        send_otp_email(user.email, otp, otp_expiry_minutes)
    except Exception as e:
        # Don't leak delivery failures to the caller -- that would both
        # confirm account existence and expose internal provider errors.
        print(f"[forgot_password] failed to send OTP email: {e}")

    return generic_response


def verify_otp(db: Session, payload: VerifyOtpRequest) -> VerifyOtpResponse:
    user = auth_repository.get_user_by_email(db, payload.email)
    # Same error for "no such user" and "wrong code" -- don't help an
    # attacker distinguish the two.
    invalid_error = HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    if not user:
        raise invalid_error

    otp_record = auth_repository.get_latest_active_otp(db, user.id)
    if not otp_record or otp_record.expires_at <= datetime.now(UTC):
        raise invalid_error

    max_attempts = int(os.getenv("OTP_MAX_ATTEMPTS", 5))
    if otp_record.attempts >= max_attempts:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Too many incorrect attempts. Please request a new code.",
        )

    if _sha256(payload.otp) != otp_record.otp_hash:
        auth_repository.increment_otp_attempts(db, otp_record)
        raise invalid_error

    auth_repository.mark_otp_used(db, otp_record)

    reset_token, expire_at = create_password_reset_token(user.id)
    expires_in = int((expire_at - datetime.now(UTC)).total_seconds())
    return VerifyOtpResponse(reset_token=reset_token, expires_in=expires_in)


def reset_password(db: Session, payload: ResetPasswordRequest) -> dict:
    token_payload = decode_password_reset_token(payload.reset_token)
    if not token_payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired reset token")

    user = auth_repository.get_user_by_id(db, UUID(token_payload["sub"]))
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if verify_password(payload.new_password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be different from your current password",
        )

    new_hash = hash_password(payload.new_password)
    auth_repository.update_password(db, user, new_hash)

    # No "current device" concept here -- the user wasn't authenticated to
    # begin with, so every existing session is revoked. They log in fresh.
    auth_repository.revoke_all_refresh_tokens(db, user.id)

    try:
        send_password_changed_email(user.email)
    except Exception as e:
        print(f"[reset_password] failed to send confirmation email: {e}")

    return {"message": "Password reset successfully. Please log in again."}


def change_password(db: Session, current_user, payload: ChangePasswordRequest) -> dict:
    if not verify_password(payload.current_password, current_user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Current password is incorrect")

    if verify_password(payload.new_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="New password must be different from your current password",
        )

    new_hash = hash_password(payload.new_password)
    auth_repository.update_password(db, current_user, new_hash)

    # Revoke every other session, then issue a fresh token pair so the
    # device the user is actively using right now stays logged in.
    auth_repository.revoke_all_refresh_tokens(db, current_user.id)
    tokens = generate_tokens(db, current_user)

    try:
        send_password_changed_email(current_user.email)
    except Exception as e:
        print(f"[change_password] failed to send confirmation email: {e}")

    return {"message": "Password changed successfully", "tokens": tokens}



# ---- Delete account ----
 
def delete_account(db: Session, current_user, payload: DeleteAccountRequest) -> dict:
    if not verify_password(payload.password, current_user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect password")
 
    # payload.confirmation == "DELETE" is already guaranteed by the schema's
    # field_validator -- FastAPI would have rejected the request with a 422
    # before this function ever ran otherwise.
 
    # Capture before the row (and thus this value) is gone.
    user_email = current_user.email
 
    try:
        auth_repository.delete_user(db, current_user)
    except IntegrityError as e:
        # Should not happen given cascade + passive_deletes is correctly
        # configured on every user-owned table -- kept as a safety net so
        # a future table added without that setup fails cleanly (409)
        # instead of crashing with a raw 500.
        db.rollback()
        print(f"[delete_account] IntegrityError: {e.orig}") 
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "This account still has associated records that couldn't be removed. "
                "Please contact support for assistance."
            ),
        )
 
    try:
        send_account_deleted_email(user_email)
    except Exception as e:
        print(f"[delete_account] failed to send confirmation email: {e}")
 
    return {"message": "Your account has been permanently deleted."}