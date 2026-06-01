from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

from core.config import settings


engine = None
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def init_db():
  global engine, SessionLocal
  if engine is None:
    engine = create_engine(
      settings.DATABASE_URL,
      pool_pre_ping=True,
      pool_recycle=1800,
      connect_args={
        "connect_timeout": 10
      }
    )
    SessionLocal.configure(bind=engine)


def get_db():
  init_db()
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()

def create_tables():
  init_db()
  Base.metadata.create_all(bind=engine)