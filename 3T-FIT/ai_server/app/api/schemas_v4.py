from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

class HealthMetrics(BaseModel):
    age: int = Field(..., ge=10, le=100)
    height_cm: float = Field(..., gt=50, lt=300)
    weight_kg: float = Field(..., gt=20, lt=500)
    bmi: Optional[float] = None
    body_fat_percentage: Optional[float] = None
    resting_heart_rate: Optional[int] = Field(None, ge=30, le=200)
    vo2max: Optional[float] = None

class UserContext(BaseModel):
    gender: str = Field(..., pattern="^(Male|Female|Other)$")
    experience_level: str = Field(..., pattern="^(Beginner|Intermediate|Advanced|Pro)$")
    activity_level: int = Field(..., ge=1, le=5)
    workout_frequency: int = Field(..., ge=1, le=14)
    injuries: Optional[List[str]] = []

class CurrentState(BaseModel):
    mood: str = Field("Neutral", description="User's current mood (Very Bad to Excellent)")
    fatigue: str = Field("Medium", description="User's current fatigue level (Very Low to Very High)")
    sleep_quality: Optional[str] = Field(None, description="Last night's sleep quality")
    stress_level: Optional[str] = Field(None, description="Current stress level")
    muscle_soreness: Optional[List[str]] = Field([], description="List of sore muscles")

class GoalContext(BaseModel):
    goal_type: str = Field(..., description="Primary goal: MuscleGain, WeightLoss, Endurance, etc.")
    target_body_parts: Optional[List[str]] = []
    duration_preference_min: Optional[int] = 60

class ExerciseCandidate(BaseModel):
    id: str
    name: str
    met_value: Optional[float] = 5.0
    primary_muscle: Optional[str] = None
    equipment: Optional[str] = None
    difficulty: Optional[str] = "Intermediate"

class RecommendRequestV4(BaseModel):
    health_metrics: HealthMetrics
    user_context: UserContext
    current_state: CurrentState
    goal_context: GoalContext
    available_exercises: Optional[List[ExerciseCandidate]] = None # If None, use internal DB
    top_k: int = 5

class RecommendationItem(BaseModel):
    exercise_id: str
    exercise_name: str
    predicted_rpe: float
    suitability_score: float
    reason: str
    suggested_params: Dict[str, Any] # sets, reps, weight, etc.

class RecommendResponseV4(BaseModel):
    recommendations: List[RecommendationItem]
    session_id: str
    model_version: str = "v4.0.0"
