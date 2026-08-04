import uuid
import pkgutil
import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

from app.database.base import Base
from app.database.init_db import engine
from app.database.session import SessionLocal

# Import existing application models safely
import app.models
from app.models.case_model import Base, CaseType, CaseStatus, CaseStage, CourtCategory

def seed_database():
    print("⏳ Synchronizing database schema configuration states...")
    for _, module_name, _ in pkgutil.walk_packages(app.models.__path__, app.models.__name__ + '.'):
        __import__(module_name)
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        # -------------------------------------------------------------
        # A. SEED SIMPLE DROPDOWNS (Case Types, Stages, Statuses)
        # -------------------------------------------------------------
        print("🚀 STEP 1: Seeding simple application static dropdown elements...")
        
        STATIC_CASE_TYPES = [
            "Criminal case", "Civil case", "Family", "Constitutional",
            "Commercial/corporate", "Labour/Employment", "Tax/Revenue",
            "NAB (corruption)", "Anti-Terrorism", "Anti-Narcotics",
            "Cybercrime", "Consumer Protection", "Environmental law",
            "Anti-Smuggling", "Banking case", "Intellectual Property",
            "Property Dispute", "Contract Dispute", "Defamation case",
            "Guardianship/Custody case"
        ]
        
        STATIC_CASE_STAGES = [
            "Case filed/Registered", "Notice issued", "Awaiting Reply/written state",
            "Preliminary Hearing", "Issues framed", "Evidence Recording",
            "Arguments/final arguments", "Judgment Reserved", "Decision announced",
            "Execution Proceedings", "Appeal/Revision Pending", "Adjourned",
            "Case dismissed", "Reopened", "Closed", "Mediation in progress",
            "Bail Hearing", "Stay order Granted", "Compromise"
        ]
        
        STATIC_CASE_STATUSES = ["Active", "Pending", "Closed", "Suspended"]

        # Seed Case Types safely
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
                
        db.commit()
        print("✅ Static attributes synced successfully.")

        # -------------------------------------------------------------
        # B. DYNAMIC DDL FIX & PURGE LEGACY HIERARCHY DATA
        # -------------------------------------------------------------
        print("\n🗑️ STEP 2: Rewriting PostgreSQL structural constraints & clearing stale records...")
        
        # 1. Truncate table data to cleanly modify constraints without data collision
        db.execute(text("TRUNCATE TABLE court_categories RESTART IDENTITY CASCADE;"))
        db.commit()

        # 2. Drop the old faulty constraint that restricted names globally
        try:
            db.execute(text("ALTER TABLE court_categories DROP CONSTRAINT IF EXISTS court_categories_name_key CASCADE;"))
            db.commit()
        except Exception as ddl_err:
            db.rollback()
            print(f"ℹ️ Note handling constraint drop: {ddl_err}")

        # 3. Add the enterprise constraint: Unique (name, parent_id)
        try:
            db.execute(text("""
                ALTER TABLE court_categories 
                ADD CONSTRAINT uq_court_category_name_parent UNIQUE (name, parent_id);
            """))
            db.commit()
            print("✅ Database constraints rewritten successfully to allow duplicate names across branches.")
        except Exception as ddl_err:
            db.rollback()
            # If it already exists from a previous modification, ignore and proceed
            pass

        # -------------------------------------------------------------
        # C. SEED HIERARCHICAL DROPDOWNS (Unified Multi-Provincial Matrix)
        # -------------------------------------------------------------
        print("\n🚀 STEP 3: Mapping 3-Layer Court Tree Data Architecture Downstream...")
        
        COURT_TREE_DATA = [
            {
                "name": "Superior Courts",
                "subcategories": [
                    {"name": "Supreme Court of Pakistan", "subcategories": []},
                    {"name": "Federal Shariat Court", "subcategories": []},
                    {
                        "name": "High Courts",
                        "subcategories": [
                            {"name": "Lahore High Court"},
                            {"name": "Sindh High Court"},
                            {"name": "Peshawar High Court"},
                            {"name": "Balochistan High Court"},
                            {"name": "Islamabad High Court"}
                        ]
                    }
                ]
            },
            {
                "name": "Subordinate Judiciary",
                "subcategories": [
                    {
                        "name": "District Courts",
                        "subcategories": [
                            {"name": "District and Sessions Judge Court"},
                            {"name": "Additional District and Sessions Judge Court"},
                            {"name": "Senior Civil Judge Court"},
                            {"name": "Civil Judges I"},
                            {"name": "Civil Judges II"},
                            {"name": "Civil Judges III"},
                            {"name": "Judicial Magistrate Court"},
                            {"name": "Family Court"},
                            {"name": "Guardian Court"},
                            {"name": "Model Civil & Criminal Courts"},
                            {"name": "Zila Qazi Court"},
                            {"name": "Camp Court (Thall)"}
                        ]
                    }
                ]
            },
            {
                "name": "Special Courts and Tribunals",
                "subcategories": [
                    {
                        "name": "KPK",
                        "subcategories": [
                            {"name": "Anti-Terrorism Court (ATC)"}, {"name": "Anti-Corruption Court"},
                            {"name": "Banking Court"}, {"name": "Consumer Court"},
                            {"name": "Customs Court"}, {"name": "Environment Tribunal"},
                            {"name": "Family Court"}, {"name": "Labour Court"},
                            {"name": "NAB Court"}, {"name": "Service Tribunal"},
                            {"name": "Tax Tribunal"}, {"name": "Drug Court"},
                            {"name": "Intellectual Property Tribunal"}, {"name": "Accountability Court"},
                            {"name": "Juvenile Court"}, {"name": "Rent Tribunal"}
                        ]
                    },
                    {
                        "name": "Punjab",
                        "subcategories": [
                            {"name": "Anti-Terrorism Court (ATC)"}, {"name": "Anti-Corruption Court"},
                            {"name": "Banking Court"}, {"name": "Consumer Court"},
                            {"name": "Customs Court"}, {"name": "Environment Tribunal"},
                            {"name": "Family Court"}, {"name": "Labour Court"},
                            {"name": "NAB Court"}, {"name": "Service Tribunal"},
                            {"name": "Tax Tribunal"}, {"name": "Drug Court"},
                            {"name": "Intellectual Property Tribunal"}, {"name": "Accountability Court"},
                            {"name": "Juvenile Court"}, {"name": "Rent Tribunal"}
                        ]
                    },
                    {
                        "name": "Balochistan",
                        "subcategories": [
                            {"name": "Anti-Terrorism Court (ATC)"}, {"name": "Anti-Corruption Court"},
                            {"name": "Banking Court"}, {"name": "Consumer Court"},
                            {"name": "Customs Court"}, {"name": "Environment Tribunal"},
                            {"name": "Family Court"}, {"name": "Labour Court"},
                            {"name": "NAB Court"}, {"name": "Service Tribunal"},
                            {"name": "Tax Tribunal"}, {"name": "Drug Court"},
                            {"name": "Intellectual Property Tribunal"}, {"name": "Accountability Court"},
                            {"name": "Juvenile Court"}, {"name": "Rent Tribunal"}
                        ]
                    },
                    {
                        "name": "Sindh",
                        "subcategories": [
                            {"name": "Anti-Terrorism Court (ATC)"}, {"name": "Anti-Corruption Court"},
                            {"name": "Banking Court"}, {"name": "Consumer Court"},
                            {"name": "Customs Court"}, {"name": "Environment Tribunal"},
                            {"name": "Family Court"}, {"name": "Labour Court"},
                            {"name": "NAB Court"}, {"name": "Service Tribunal"},
                            {"name": "Tax Tribunal"}, {"name": "Drug Court"},
                            {"name": "Intellectual Property Tribunal"}, {"name": "Accountability Court"},
                            {"name": "Juvenile Court"}, {"name": "Rent Tribunal"}
                        ]
                    }
                ]
            }
        ]

        # RECURSIVE ENGINE: Validates path-specific uniqueness before insertions
        def insert_court_node(node_dict, parent_id=None):
            court_name = node_dict["name"]
            
            # Query name combined with parent path context
            exists = db.query(CourtCategory).filter(
                CourtCategory.name == court_name,
                CourtCategory.parent_id == parent_id
            ).first()
            
            if not exists:
                current_id = str(uuid.uuid4())
                new_node = CourtCategory(
                    id=current_id,
                    name=court_name,
                    parent_id=parent_id
                )
                db.add(new_node)
                db.flush() 
                assigned_id = current_id
            else:
                assigned_id = exists.id

            # Recurse downstream elements cleanly
            if "subcategories" in node_dict and node_dict["subcategories"]:
                for sub_node in node_dict["subcategories"]:
                    insert_court_node(sub_node, parent_id=assigned_id)

        # Map complete data collection configurations
        for root_category in COURT_TREE_DATA:
            print(f" -> Mapping Hierarchical Root Node: {root_category['name']}")
            insert_court_node(root_category, parent_id=None)

        db.commit()
        print("\n🎉 SUCCESSFULLY INITIALIZED DATABASES AND SYNCED THE 3-TIER COURT SYSTEM!")

    except Exception as e:
        db.rollback()
        print(f"\n❌ Error seeding database (Rollback performed cleanly): {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()


#this is seeding file that write the static data in the database tables
#  like, Types, Stages, Statuses and CourtCategories
# and it can be run individually using terminal = "python -m app.models.seed_data"