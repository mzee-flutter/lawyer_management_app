from sqlalchemy.orm import Session
from sqlalchemy import or_, asc, desc
from app.models.client_model import Client
from app.schemas.client_schema import ClientCreate, ClientUpdate
from datetime import datetime, timezone


class ClientRepository:

    @staticmethod
    def create(db: Session, client_in: ClientCreate) -> Client:
        db_client = Client(**client_in.dict())
        db.add(db_client)
        db.commit()
        db.refresh(db_client)
        return db_client

    @staticmethod
    def get_by_id(db: Session, client_id) -> Client | None:
        return db.query(Client).filter(Client.id == client_id).first()

    @staticmethod
    def search(
        db: Session,
        query: str | None,
        skip: int = 0,
        limit: int = 10,
        sort: str | None = None
    ) -> list[Client]:
        q = db.query(Client)

        # 🔎 Filtering
        if query:
            q = q.filter(
                or_(
                    Client.name.ilike(f"%{query}%"),
                    Client.email.ilike(f"%{query}%"),
                    Client.phone.ilike(f"%{query}%"),
                    Client.cnic.ilike(f"%{query}%"),
                )
            )

        # ↕ Sorting
        if sort:
            try:
                field, direction = sort.split(",")
                sort_column = getattr(Client, field)
                if direction.lower() == "desc":
                    q = q.order_by(desc(sort_column))
                else:
                    q = q.order_by(asc(sort_column))
            except Exception:
                raise ValueError("Invalid sort format. Use field,asc or field,desc")

        # 📄 Pagination
        return q.offset(skip).limit(limit).all()

    @staticmethod
    def update(db: Session, client: Client, client_in: ClientUpdate) -> Client:
        for field, value in client_in.dict(exclude_unset=True).items():
            setattr(client, field, value)
        client.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(client)
        return client

    @staticmethod
    def archive(db: Session, client: Client) -> Client:
        client.archived_at = datetime.utcnow()
        db.commit()
        db.refresh(client)
        return client
