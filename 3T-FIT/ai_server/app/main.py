
from fastapi import FastAPI, HTTPException
from recommend_schemas import RecommendRequest
from recommend import recommend
from recommend_v3 import recommend_v3, validate_profile_for_v3, get_goal_suggestions
from model_v3 import load_model_v3
from preprocess_v3 import load_preprocessor_v3
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="OmniMer Health Recommendation API", version="2.0.0")

# Load Model v3 on startup
@app.on_event("startup")
async def startup_event():
    """Load Model v3 and preprocessor on app startup"""
    try:
        logger.info("Loading Model v3...")
        model_loaded = load_model_v3()
        preprocessor_loaded = load_preprocessor_v3()

        if model_loaded and preprocessor_loaded:
            logger.info("✅ Model v3 and preprocessor loaded successfully")
        else:
            logger.warning("⚠️ Model v3 loading failed, falling back to v1")

    except Exception as e:
        logger.error(f"❌ Failed to load Model v3: {e}")

@app.post("/recommend")
def get_recommendation(req: RecommendRequest):
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

@app.post("/recommend/v3")
def get_recommendation_v3(req: RecommendRequest):
    """
    Enhanced recommendation endpoint using Model v3
    with improved capability prediction and rule-based decoding
    """
    try:
        profile = req.profile
        top_k = req.top_k or 5

        # Extract goal from profile or use default
        goal = profile.goal_type or "hypertrophy"
        if isinstance(goal, list) and goal:
            goal = goal[0]  # Take first goal if it's a list
        elif isinstance(goal, list):
            goal = "general_fitness"  # Default if empty list

        # Validate profile for Model v3
        is_valid, error_msg = validate_profile_for_v3(profile.dict())
        if not is_valid:
            raise HTTPException(status_code=400, detail=f"Profile validation failed: {error_msg}")

        logger.info("Data profile from backend: %s", profile.dict())

        # Generate recommendation using Model v3
        result = recommend_v3(
            profile=profile.dict(),
            top_k=top_k,
            goal=goal,
            target_duration=30.0  # Default 30 minutes for cardio
        )

        logger.info("Result from AI (v3): exercises=%d, goal=%s",
                   len(result.get("exercises", [])), goal)

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error in v3 recommendation: %s", str(e))
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/recommend/v3/enhanced")
def get_recommendation_v3_enhanced(req: RecommendRequest):
    """
    Enhanced v3 endpoint with goal suggestions and additional features
    """
    try:
        profile = req.profile
        top_k = req.top_k or 5

        # Validate profile
        is_valid, error_msg = validate_profile_for_v3(profile.dict())
        if not is_valid:
            raise HTTPException(status_code=400, detail=f"Profile validation failed: {error_msg}")

        # Get goal suggestions
        goal_suggestions = get_goal_suggestions(profile.dict())

        # Use primary suggested goal or user's goal
        primary_goal = profile.goal_type or "general_fitness"
        if isinstance(primary_goal, list) and primary_goal:
            primary_goal = primary_goal[0]
        elif isinstance(primary_goal, list):
            # Use highest priority suggestion
            user_goals = [s["goal"] for s in goal_suggestions if s["priority"] == "high"]
            primary_goal = user_goals[0] if user_goals else "general_fitness"

        # Get high priority suggestions for user
        high_priority_goals = [s for s in goal_suggestions if s["priority"] in ["high", "user_preference"]]

        logger.info("Enhanced v3 recommendation: goal=%s, suggestions=%d",
                   primary_goal, len(goal_suggestions))

        # Generate recommendation
        result = recommend_v3(
            profile=profile.dict(),
            top_k=top_k,
            goal=primary_goal,
            target_duration=30.0
        )

        # Add goal suggestions to response
        result["goalSuggestions"] = goal_suggestions
        result["recommendedGoal"] = primary_goal
        result["highPriorityGoals"] = high_priority_goals

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error in enhanced v3 recommendation: %s", str(e))
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "OmniMer Health Recommendation API is running"}

@app.get("/model/info")
def get_model_info():
    """Get information about available models"""
    try:
        from model_v3 import get_model_v3_info

        v3_info = get_model_v3_info()

        return {
            "models": {
                "v1": {
                    "status": "available",
                    "description": "Original recommendation model",
                    "endpoint": "/recommend"
                },
                "v3": {
                    "status": "loaded" if v3_info else "not_loaded",
                    "description": "Enhanced capability prediction model",
                    "endpoint": "/recommend/v3",
                    "info": v3_info
                }
            }
        }
    except Exception as e:
        logger.error("Error getting model info: %s", str(e))
        return {
            "models": {
                "v1": {"status": "available"},
                "v3": {"status": "error", "error": str(e)}
            }
        }
