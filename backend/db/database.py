from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

from core.config import settings


engine = create_engine(
  settings.DATABASE_URL,
  pool_pre_ping=True,
  pool_recycle=1800,
  connect_args={
    "connect_timeout": 10
  }
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()

def create_tables():
  Base.metadata.create_all(bind=engine)