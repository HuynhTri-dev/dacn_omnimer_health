from typing import List
from pydantic import BaseModel

class HealthStatus(BaseModel):
    injuries: List[str] = []

class HealthProfile(BaseModel):
    gender: str
    age: int
    height: float
    weight: float
    bmi: float
    bodyFatPercentage: float
    activityLevel: int
    experienceLevel: str
    workoutFrequency: int
    restingHeartRate: int
    healthStatus: HealthStatus

class Goal(BaseModel):
    goalType: str
    targetMetric: List[str] = []
