import uuid
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database.base import Base
from app.database.init_db import engine
from app.database.session import SessionLocal
from dotenv import load_dotenv
import os

from app.models.case_model import Base, CaseType, CaseStatus, CaseStage, CourtCategory




def seed_database():
    import pkgutil
    import app.models
    for _, module_name, _ in pkgutil.walk_packages(app.models.__path__, app.models.__name__ + '.'):
        __import__(module_name)
    # This automatically reads your existing models and creates the exact tables in Postgres
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        # -------------------------------------------------------------
        # A. SEED SIMPLE DROPDOWNS (Case Types, Stages, Statuses)
        # -------------------------------------------------------------
        # Replace these arrays with your exact static strings
        STATIC_CASE_TYPES = ["Civil", "Criminal", "Family", "Corporate"]
        STATIC_CASE_STAGES = ["Filing", "Discovery", "Trial", "Appeal"]
        STATIC_CASE_STATUSES = ["Active", "Pending", "Closed", "Suspended"]

        # Seed Case Types safely (skips if name already exists)
        for name in STATIC_CASE_TYPES:
            if not db.query(CaseType).filter(CaseType.name == name).first():
                db.add(CaseType(name=name))

        # Seed Case Stages safely
        for name in STATIC_CASE_STAGES:
            if not db.query(CaseStage).filter(CaseStage.name == name).first():
                db.add(CaseStage(name=name))

        # Seed Case Statuses safely
        for name in STATIC_CASE_STATUSES:
            if not db.query(CaseStatus).filter(CaseStatus.name == name).first():
                db.add(CaseStatus(name=name))

        # -------------------------------------------------------------
        # B. SEED HIERARCHICAL DROPDOWNS (Court Categories & Sub-categories)
        # -------------------------------------------------------------
        # Structure your fixed categories and their children here
        COURT_DATA = {
            "Supreme Court": [], 
            "High Court": ["Civil Division", "Criminal Division", "Commercial Division"],
            "District Court": ["Family Court", "Juvenile Court", "Traffic Court"]
        }

        for parent_name, subcategories in COURT_DATA.items():
            # Check if parent category exists
            parent = db.query(CourtCategory).filter(CourtCategory.name == parent_name).first()
            if not parent:
                parent = CourtCategory(name=parent_name)
                db.add(parent)
                db.flush() # Forces SQLAlchemy to generate the parent's UUID right away

            # Check and seed subcategories linked to this parent
            for sub_name in subcategories:
                exists = db.query(CourtCategory).filter(
                    CourtCategory.name == sub_name, 
                    CourtCategory.parent_id == parent.id
                ).first()
                if not exists:
                    db.add(CourtCategory(name=sub_name, parent_id=parent.id))

        db.commit()
        print("🎉 Successfully created tables and seeded your fixed dropdown data!")

    except Exception as e:
        db.rollback()
        print(f"❌ Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()



#This is the seeding file which mean it will the create the static data table 
#I have to just provide the actual list 