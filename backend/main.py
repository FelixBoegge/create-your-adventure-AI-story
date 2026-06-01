from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import settings
from routers import story, job
from db.database import create_tables, init_db
import asyncio
from contextlib import asynccontextmanager


@asynccontextmanager
async def lifespan(app: FastAPI):
  print("Container booted successfully. Initiating database connection...")

  for attempt in range(5):
    try:
      init_db()
      create_tables()
      print("DB connected and tables verified successfully.")
      break
    except Exception as e:
      print(f"DB connection attempt {attempt} failed: {e}. Retrying in 5 seconds.")
      await asyncio.sleep(5)
  else:
    raise RuntimeError("Could not connect to DB after 5 attempts.")
  
  yield
  print("Shutting down container application.")


app = FastAPI(
  title="Create your own adventure story API",
  description="api to generate cool stories",
  version="0.1.0",
  docs_url="/docs",
  redoc_url="/redoc",
  lifespan=lifespan
)


app.add_middleware(
  CORSMiddleware,
  allow_origins=settings.ALLOWED_ORIGINS,
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"]
)


app.include_router(story.router, prefix=settings.API_PREFIX)
app.include_router(job.router, prefix=settings.API_PREFIX)


if __name__ == "__main__":
  import uvicorn
  uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)