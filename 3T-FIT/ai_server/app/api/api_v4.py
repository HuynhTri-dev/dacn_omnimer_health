from fastapi import APIRouter, HTTPException
from schema.recommend_schemas import RecommendInput, RecommendOutput
from services.recommendation_v4 import recommendation_service

router = APIRouter()

@router.post("/recommend", response_model=RecommendOutput)
async def recommend_exercises(input_data: RecommendInput):
    """
    Recommend exercises based on user profile and goals.
    """
    try:
        result = recommendation_service.recommend_exercises(input_data)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
