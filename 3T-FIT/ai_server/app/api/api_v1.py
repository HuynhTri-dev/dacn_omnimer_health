from fastapi import APIRouter, HTTPException
from schema.recommend_schemas import RecommendInput
from services.recommendation_v1 import recommend
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/recommend")
def get_recommendation(req: RecommendInput):
    """Legacy endpoint using Model v1 for backward compatibility"""
    try:
        profile = req.profile
        top_k = req.top_k or 5

        logger.info("Data profile from backend: %s", profile.dict())
        result = recommend(profile.dict(), top_k=top_k)
        logger.info("Result from AI (v1): %s", result)
        return result
    except Exception as e:
        logger.error("Error in v1 recommendation: %s", str(e))
        raise HTTPException(status_code=500, detail=str(e))
