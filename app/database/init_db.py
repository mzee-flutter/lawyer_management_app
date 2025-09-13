from sqlalchemy import create_engine
from dotenv import load_dotenv
import os



load_dotenv()

url= os.getenv("DATABASE_URL")

engine = create_engine(url=url) 


