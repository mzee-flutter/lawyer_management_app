from sqlalchemy import create_engine
from base import Base
from dotenv import load_dotenv
import os



load_dotenv()

url= os.getenv("DATABASE_URL")

engine = create_engine(url=url) 


Base.metadata.create_all(bind = engine)
