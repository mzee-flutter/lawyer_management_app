from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.database.base import Base
from app.database.init_db import engine
from contextlib import asynccontextmanager
from app.routers import (auth_routers)
from app.routers import case_routers
from app.routers import hearing_routers
from app.routers import court_portal_router
from app.routers import legal_task_router
from app.routers import scan_router
from app.models import auth_model
from app.models import scan_model

from app.routers import client_routers
from app.models.case_model import Case, CaseFile, CaseStage, CaseStatus, CaseType,  CourtCategory
from app.workers.scheduler import start_notification_scheduler


#All the tables must be imported in the base.py file before run the command  
#this is the startup function that ensure that the table are created which we have define it in the model
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind= engine)
    start_notification_scheduler()

    yield





app= FastAPI(title="Lawyer App Backend", lifespan=lifespan, docs_url="/docs", redoc_url="/redoc", openapi_url="/openapi.json")

   
app.include_router(auth_routers.router)
app.include_router(client_routers.router)
app.include_router(case_routers.router)
app.include_router(hearing_routers.hearing_router)
app.include_router(court_portal_router.court_router)
app.include_router(legal_task_router.task_router)
app.include_router(scan_router.scan_router)

app.mount("/uploads", StaticFiles(directory= "uploads"), name="uploads")



























#Ctrl + shift + P will give search bar for selecting interpreter for the virtual environment. 