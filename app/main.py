from fastapi import FastAPI
from app.database.base import Base
from app.database.init_db import engine
from contextlib import asynccontextmanager
from app.routers import (auth_routers)
from app.models import auth_model



#this is the startup function that ensure that the table are created which we have define it in the model
async def lifespan(app=FastAPI):
    Base.metadata.create_all(bind= engine)

    yield





app= FastAPI(title="Lawyer App Backend", lifespan=lifespan, docs_url="/docs", redoc_url="/redoc", openapi_url="/openai.json")

app.include_router(auth_routers.router)




























#Ctrl + shift + P will give search bar for selecting interpreter for the virtual environment. 