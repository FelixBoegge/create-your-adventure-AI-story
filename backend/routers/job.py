import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Cookie
from sqlalchemy.orm import Session

from db.database import get_db
from models.job import StoryJob
from schemas.job import StoryJobResponse


router = APIRouter(
  prefix="/jobs",
  tags=["jobs"]
)


@router.get("/{job_id}", response_model=StoryJobResponse)
def get_job_status(job_id: str, db: Session = Depends(get_db)):
  job = db.query(StoryJob).filter(StoryJob.job_id == job_id).first()

  if not job:
    raise HTTPException(status_code=404, detail="Job not found")
  
  return job


@router.get("/debug-choreo")
def debug():
    import os
    return {
        "serviceurl": os.getenv("CHOREO_OPENAI_CONNECTION_SERVICEURL"),
        "consumer_key": bool(os.getenv("CHOREO_OPENAI_CONNECTION_CONSUMERKEY")),
        "consumer_secret": bool(os.getenv("CHOREO_OPENAI_CONNECTION_CONSUMERSECRET")),
        "token_url": bool(os.getenv("CHOREO_OPENAI_CONNECTION_TOKENURL")),
    }