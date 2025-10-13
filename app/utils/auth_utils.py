from passlib.context import CryptContext
import secrets, hashlib
from jose import JWTError, jwt
from datetime import datetime, timedelta, UTC
from dotenv import load_dotenv
import os


load_dotenv()



pwd_context= CryptContext(schemes=["bcrypt"], deprecated= "auto")



def hash_password(password:str)->str:
    return pwd_context.hash(password)


def verify_password(plain_password:str, hash_password:str)->bool:
    return pwd_context.verify(plain_password, hash_password)
    



def _sha256(input: str):
    return hashlib.sha256(input.encode()).hexdigest()



def create_access_token(data:dict):
    to_encode= data.copy()
    expire_in= datetime.now() +timedelta(minutes= int(os.getenv("ACCESS_TOKEN_EXPIRY_MIN")))
    to_encode.update({"exp":expire_in})

    access_token= jwt.encode(to_encode, os.getenv("JWT_SECRET_KEY"), algorithm=os.getenv("ALGORITHM"))
    return access_token, expire_in




def create_refresh_token():
    raw_refresh= secrets.token_urlsafe(64)
    return raw_refresh, _sha256(raw_refresh)


def decode_accesss_token(token:str):
    try:
        payload= jwt.decode(token, os.getenv("JWT_SECRET_KEY"), os.getenv("ALGORITHM"))
        return payload
    except JWTError as e:
        print("JWT decode error: ", e )
        return None