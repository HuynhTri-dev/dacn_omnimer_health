from typing import List, Optional
from pydantic import BaseModel
from schema.common_schemas import HealthProfile, Goal

# --- Recommend Input ---

class ExerciseInput(BaseModel):
    exerciseId: str
    exerciseName: str

class RecommendInput(BaseModel):
    healthProfile: HealthProfile
    goals: List[Goal]
    exercises: List[ExerciseInput]
    k: int

# --- Recommend Output ---

class SetDetail(BaseModel):
    reps: Optional[int] = None
    kg: Optional[float] = None
    distance: Optional[float] = None
    duration: Optional[int] = None
    restAfterSetSeconds: Optional[int] = None

class RecommendedExercise(BaseModel):
    name: str
    sets: List[SetDetail]

class RecommendOutput(BaseModel):
    exercises: List[RecommendedExercise]
