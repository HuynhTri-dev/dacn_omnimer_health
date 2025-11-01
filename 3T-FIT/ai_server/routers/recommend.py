from fastapi import APIRouter
from app.models.rag_engine import get_similar_workouts
from app.models.ml_model import predict_scores

router = APIRouter(prefix="/ai")

@router.post("/recommend")
async def recommend(user_data: dict):
    candidates = get_similar_workouts(user_data)
    results = predict_scores(user_data, candidates)
    return {"recommendations": results}
