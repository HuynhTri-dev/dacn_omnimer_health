# app/schemas.py
from pydantic import BaseModel
from typing import Optional, Dict, Any, List

class UserProfile(BaseModel):
    age: int
    height_cm: float
    weight_kg: float
    bmi: float
    body_fat_percentage: float
    whr: float
    resting_hr: int
    workout_frequency_per_week: Optional[int] = None
    gender: str
    experience_level: Optional[str] = None
    activity_level: Optional[int] = None
    health_status: Optional[Dict[str, Any]] = None
    goal_type: Optional[str] = None
    target_metric: Optional[Dict[str, Any]] = None
    exercises: Optional[List[Dict[str, Any]]] = []

# Mới: schema cho request lồng profile + top_k
class RecommendRequest(BaseModel):
    profile: UserProfile
    top_k: Optional[int] = 5
