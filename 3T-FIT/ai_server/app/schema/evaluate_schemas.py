from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
from app.schema.common_schemas import HealthProfile

# --- Evaluate Input ---

class WorkoutSet(BaseModel):
    id: Optional[str] = Field(None, alias="_id")
    setOrder: Optional[int] = None
    reps: Optional[int] = None
    weight: Optional[float] = None
    restAfterSetSeconds: Optional[int] = None
    notes: Optional[str] = None
    done: Optional[bool] = None
    distance: Optional[float] = None
    duration: Optional[int] = None

class DeviceData(BaseModel):
    heartRateAvg: Optional[int] = None
    heartRateMax: Optional[int] = None
    caloriesBurned: Optional[int] = None

class WorkoutDetailItem(BaseModel):
    id: Optional[str] = Field(None, alias="_id")
    exerciseId: str
    type: str  # "reps", "distance", "time"
    sets: List[WorkoutSet]
    durationMin: float
    deviceData: Optional[DeviceData] = None

class WorkoutSummary(BaseModel):
    heartRateAvgAllWorkout: Optional[int] = None
    heartRateMaxAllWorkout: Optional[int] = None
    totalSets: Optional[int] = None
    totalReps: Optional[int] = None
    totalWeight: Optional[float] = None
    totalDuration: Optional[int] = None
    totalCalories: Optional[int] = None
    totalDistance: Optional[float] = None

class EvaluateInput(BaseModel):
    healthProfile: HealthProfile
    timeStart: datetime
    notes: Optional[str] = None
    workoutDetail: List[WorkoutDetailItem]
    summary: Optional[WorkoutSummary] = None
    createdAt: Optional[datetime] = None
    updatedAt: Optional[datetime] = None

# --- Evaluate Output ---

class EvaluateResultItem(BaseModel):
    exerciseName: str
    intensityScore: int
    suitability: float
