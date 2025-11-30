from typing import List, Optional, Any
from pydantic import BaseModel

class HealthStatus(BaseModel):
    knownConditions: List[str] = []
    painLocations: List[str] = []
    jointIssues: List[str] = []
    injuries: List[str] = []
    abnormalities: List[str] = []
    notes: str = ""

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
    maxWeightLifted: float
    healthStatus: HealthStatus

class TargetMetric(BaseModel):
    metricName: str
    value: float
    unit: str

class Goal(BaseModel):
    goalType: str
    targetMetric: List[TargetMetric] = []
