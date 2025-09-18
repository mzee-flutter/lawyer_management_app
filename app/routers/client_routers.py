from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from uuid import UUID  # enforce UUID instead of str
from app.database.session import get_db
from app.schemas.client_schema import ClientCreate, ClientUpdate, ClientPublic
from app.services.client_service import ClientService

router = APIRouter(prefix="/api/v1/clients", tags=["Clients"])




@router.get("/", response_model=list[ClientPublic])
def list_clients(
    q: str | None = Query(None, description="Search by name, email, phone, or CNIC"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    sort: str | None = Query(None, description="Sort by field, e.g. name,asc"),
    db: Session = Depends(get_db),
):
    
    return ClientService.search_clients(db, q=q, page=page, size=size, sort=sort)



@router.get("/archived", response_model=list[ClientPublic])
def list_archived_clients(
    q: str | None = Query(None, description="Search by name, email, phone, or CNIC"),
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, description="Page size"),
    sort: str | None = Query(None, description="Sort by field, e.g. name,asc"),
    db: Session = Depends(get_db),
):
    
    return ClientService.search_archived_clients(db, q=q, page=page, size=size, sort=sort)

@router.delete("/{client_id}/permanent", response_model=ClientPublic)
def delete_client_permanently(client_id:str, db: Session= Depends(get_db)):
    return ClientService.delete_client_permanently(db, client_id)


@router.put("/{client_id}/restore", response_model=ClientPublic)
def restore_client(client_id: str, db: Session = Depends(get_db)):
    return ClientService.restore_client(db, client_id)



@router.post("/", response_model=ClientPublic)
def create_client(client_in: ClientCreate, db: Session = Depends(get_db)):
    """Create a new client"""
    return ClientService.create_client(db, client_in)


@router.get("/{client_id}", response_model=ClientPublic)
def get_client(client_id: UUID, db: Session = Depends(get_db)):
    
    return ClientService.get_client(db, client_id)


@router.patch("/{client_id}", response_model=ClientPublic)
def update_client(client_id: UUID, client_in: ClientUpdate, db: Session = Depends(get_db)):
    
    return ClientService.update_client(db, client_id, client_in)


@router.delete("/{client_id}", response_model=ClientPublic)
def archive_client(client_id: UUID, db: Session = Depends(get_db)):
  
    return ClientService.archive_client(db, client_id)
