from sqlalchemy.orm import Session
from app.models.auth_model import User, RefreshToken, PasswordResetOTP
from uuid import UUID


def get_user_by_id(db:Session, id:UUID):
    db_user= db.query(User).filter(User.id==id).first()
    return db_user

def get_user_by_email(db:Session, email:str)-> User:
    db_user= db.query(User).filter(User.email==email).first()
    return db_user


def create_user(db:Session, name:str, email:str, hashed_password:str)->User:
    new_user= User(name=name, email= email, password_hash=hashed_password )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user



def save_refresh_token(db:Session, user_id:int, token_hash:str, expire_at)-> RefreshToken:
    db_refresh= RefreshToken(user_id=user_id, token_hash= token_hash, expire_at=expire_at)
    db.add(db_refresh)
    db.commit()
    return db_refresh



def get_refresh_token(db:Session, token_hash:str)-> RefreshToken | None:
    db_refresh_token= db.query(RefreshToken).filter(RefreshToken.token_hash==token_hash).first()
    return db_refresh_token



def revoke_refresh_token(db:Session, token:RefreshToken):
    token.revoked=True
    db.commit()


def update_fcm_token(db: Session, user: User, fcm_token: str) -> User:
    user.fcm_token = fcm_token
    db.commit()
    db.refresh(user)
    return user


# ---- Password management ----

def update_password(db: Session, user: User, new_password_hash: str) -> User:
    user.password_hash = new_password_hash
    db.commit()
    db.refresh(user)
    return user


def revoke_all_refresh_tokens(db: Session, user_id: UUID, except_token_hash: str | None = None) -> None:
    """
    Revokes every active refresh token for a user (used after password
    change/reset to force logout on other devices). Pass except_token_hash
    to keep the current device's session alive.
    """
    query = db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.revoked == False,
    )
    if except_token_hash:
        query = query.filter(RefreshToken.token_hash != except_token_hash)

    query.update({"revoked": True}, synchronize_session=False)
    db.commit()


# ---- Password reset OTPs ----

def create_password_reset_otp(db: Session, user_id: UUID, otp_hash: str, expires_at) -> PasswordResetOTP:
    db_otp = PasswordResetOTP(user_id=user_id, otp_hash=otp_hash, expires_at=expires_at)
    db.add(db_otp)
    db.commit()
    db.refresh(db_otp)
    return db_otp


def get_latest_active_otp(db: Session, user_id: UUID) -> PasswordResetOTP | None:
    return (
        db.query(PasswordResetOTP)
        .filter(PasswordResetOTP.user_id == user_id, PasswordResetOTP.is_used == False)
        .order_by(PasswordResetOTP.created_at.desc())
        .first()
    )


def get_last_otp_request_time(db: Session, user_id: UUID):
    last = (
        db.query(PasswordResetOTP)
        .filter(PasswordResetOTP.user_id == user_id)
        .order_by(PasswordResetOTP.created_at.desc())
        .first()
    )
    return last.created_at if last else None


def invalidate_active_otps(db: Session, user_id: UUID) -> None:
    db.query(PasswordResetOTP).filter(
        PasswordResetOTP.user_id == user_id,
        PasswordResetOTP.is_used == False,
    ).update({"is_used": True}, synchronize_session=False)
    db.commit()


def increment_otp_attempts(db: Session, otp: PasswordResetOTP) -> None:
    otp.attempts += 1
    db.commit()


def mark_otp_used(db: Session, otp: PasswordResetOTP) -> None:
    otp.is_used = True
    db.commit()


# ---- Account deletion ----
 
def delete_user(db: Session, user: User) -> None:
    """
    Cascade behavior lives entirely on the User model's relationships
    (cascade="all, delete-orphan" + passive_deletes=True on every
    user-owned table, confirmed already set up correctly) -- this function
    just triggers it.
    """
    db.delete(user)
    db.commit()