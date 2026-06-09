from fastapi.testclient import TestClient
from main import app
from core.config import settings
from routers.test import router


client = TestClient(app)


def test_health_check():
  response = client.get(f"{settings.API_PREFIX}{router.prefix}/")
  assert response.status_code == 200
  data = response.json()
  assert data["status"] == "healthy"
  assert data["version"] == "1.1.0"


def test_read_item():
  response = client.get(f"{settings.API_PREFIX}{router.prefix}/items/42?q=test")
  assert response.status_code == 200
  data = response.json()
  assert data["item_id"] == 42
  assert data["query"] == "test"


def test_read_item_no_query():
  response = client.get(f"{settings.API_PREFIX}{router.prefix}/items/1")
  assert response.status_code == 200
  data = response.json()
  assert data["item_id"] == 1
  assert data["query"] is None


def test_app_info():
  response = client.get(f"{settings.API_PREFIX}{router.prefix}/info")
  assert response.status_code == 200
  data = response.json()
  assert data["app_name"] == settings.APP_TITLE
  assert "/" in data["endpoints"]
