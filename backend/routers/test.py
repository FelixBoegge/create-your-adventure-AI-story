from fastapi import APIRouter
from core.config import settings


router = APIRouter(
  prefix="/tests",
  tags=["tests"]
)

@router.get("/")
def health_check():
  return {"status": "broken", "version": "1.1.0"}


@router.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
  return {"item_id": item_id, "query": q}


@router.get("/info")
def app_info():
  return {
    "app_name": f"{settings.APP_TITLE}",
    "description": f"{settings.APP_DESCRIPTION}",
    "endpoints": ["/", "/items/{item_id}", "/info"],
  }
