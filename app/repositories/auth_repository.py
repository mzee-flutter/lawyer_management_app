from sqlalchemy.orm import Session
from app.models.auth_model import User, RefreshToken


def get_user_by_id(db:Session, id:int):
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
