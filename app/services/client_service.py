from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.client_repository import ClientRepository
from app.schemas.client_schema import ClientCreate, ClientUpdate, ClientPublic


class ClientService:

    @staticmethod
    def create_client(db: Session, client_in: ClientCreate) -> ClientPublic:
        client = ClientRepository.create(db, client_in)
        return ClientPublic.model_validate(client)

    @staticmethod
    def get_client(db: Session, client_id) -> ClientPublic:
        client = ClientRepository.get_by_id(db, client_id)
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")
        return ClientPublic.model_validate(client)

    @staticmethod
    def search_clients(
    db: Session,
    q: str | None = None,
    page: int = 1,
    size: int = 10,
    sort: str | None = None
) -> list[ClientPublic]:
        skip = (page - 1) * size
        clients = ClientRepository.search(db, query=q, skip=skip, limit=size, sort=sort)
        return [ClientPublic.model_validate(c) for c in clients]
    
    @staticmethod
    def search_archived_clients(
        db:Session,
        q: str | None= None,
        page: int= 1,
        size: int = 10,
        sort: str |None= None,
        )->list[ClientPublic]:
        skip= (page - 1) * size
        clients= ClientRepository.search_archived(db, query=q, skip=skip, limit=size, sort=sort)
        return [ClientPublic.model_validate(c) for c in clients]


    @staticmethod
    def restore_client(db, client_id: str) -> ClientPublic:
        client = ClientRepository.get_by_id(db, client_id)
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")

        if client.archived_at is None:
            raise HTTPException(status_code=400, detail="Client is not archived")

        restored = ClientRepository.restore(db, client)
        return ClientPublic.model_validate(restored)
    


    @staticmethod
    def delete_client_permanently(db:Session, client_id:str)-> ClientPublic:
        client= ClientRepository.get_by_id(db, client_id)

        if not client:
            raise HTTPException(status_code=404, detail="Client not Found")
        
        copy_client= ClientPublic.model_validate(client)
        ClientRepository.delete(db, client)
        
        return copy_client


    @staticmethod
    def update_client(db: Session, client_id, client_in: ClientUpdate) -> ClientPublic:
        client = ClientRepository.get_by_id(db, client_id)
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")
        updated = ClientRepository.update(db, client, client_in)
        return ClientPublic.model_validate(updated)

    @staticmethod
    def archive_client(db: Session, client_id) -> ClientPublic:
        client = ClientRepository.get_by_id(db, client_id)
        if not client:
            raise HTTPException(status_code=404, detail="Client not found")
        archived = ClientRepository.archive(db, client)
        return ClientPublic.model_validate(archived)
