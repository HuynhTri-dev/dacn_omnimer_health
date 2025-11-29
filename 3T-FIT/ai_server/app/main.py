from fastapi import FastAPI
# from api.api_v1 import router as api_v1_router
# from api.api_v3 import router as api_v3_router
from api.api_v4 import router as api_v4_router
from services.recommendation_v4 import load_model_v4_artifacts
# from models.model_v3 import load_model_v3
# from utils.preprocess_v3 import load_preprocessor_v3
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="OmniMer Health Recommendation API", version="4.0.0")

# Include Routers
# V1: /recommend (Legacy) - We can mount it at root or /v1. 
# The original code had /recommend at root. Let's keep /recommend at root via v1 router, or mount at /v1.
# User asked to separate each api version.
# Let's mount v1 at /v1 and also include the root /recommend if needed for backward compatibility, 
# but usually separating means /v1/..., /v2/...
# However, to maintain backward compatibility with existing clients calling /recommend, we might need to keep it.
# But the user request is "tách mỗi đầu api của version sẽ khác nhau chia vào app/api".
# I will mount them as:
# /v1
# /v3
# /v4
# And I will also include v1 router at root to preserve /recommend if that was the intention, 
# OR I will just follow the strict versioning.
# Given the previous main.py had /recommend, /recommend/v3, /v4/recommend.
# I will map:
# api_v1_router -> /v1 (and maybe / for legacy /recommend)
# api_v3_router -> /v3 (so /v3/recommend)
# api_v4_router -> /v4 (so /v4/recommend)

# app.include_router(api_v1_router, prefix="/v1", tags=["v1"])
# To support the exact old path "/recommend", we can include it without prefix or handle it specifically.
# The old main.py had @app.post("/recommend").
# I will add a redirect or just include it at root for backward compatibility if needed, 
# but for "separation", /v1/recommend is cleaner. 
# I'll stick to the requested structure of separating versions. 
# But wait, api_v1.py has @router.post("/recommend"). So app.include_router(api_v1_router, prefix="/v1") makes it /v1/recommend.
# That looks correct.

# app.include_router(api_v3_router, prefix="/v3", tags=["v3"]) 
# api_v3.py has @router.post("/recommend"). So this becomes /v3/recommend.
# It also has /recommend/enhanced -> /v3/recommend/enhanced.

app.include_router(api_v4_router, prefix="/v4", tags=["v4"])
# api_v4.py has @router.post("/recommend"). So this becomes /v4/recommend.

# Load Models on startup
@app.on_event("startup")
async def startup_event():
    """Load Models (v3, v4) and artifacts on app startup"""
    try:
        # Load V3
        # logger.info("Loading Model v3...")
        # model_v3_loaded = load_model_v3()
        # preprocessor_v3_loaded = load_preprocessor_v3()
        
        # if model_v3_loaded and preprocessor_v3_loaded:
        #     logger.info("✅ Model v3 loaded successfully")
        # else:
        #     logger.warning("⚠️ Model v3 loading failed")

        # Load V4
        logger.info("Loading Model v4...")
        # Adjust path to point to correct model directory relative to app/main.py
        model_v4_loaded = load_model_v4_artifacts("../model/src/v4/model_v4")
        
        if model_v4_loaded:
            logger.info("✅ Model v4 loaded successfully")
        else:
            logger.warning("⚠️ Model v4 loading failed")

    except Exception as e:
        logger.error(f"❌ Failed to load models: {e}")

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "OmniMer Health Recommendation API is running"}

@app.get("/model/info")
def get_model_info():
    """Get information about available models"""
    try:
        # from models.model_v3 import get_model_v3_info
        # v3_info = get_model_v3_info()
        
        return {
            "models": {
                # "v1": {
                #     "status": "available",
                #     "description": "Original recommendation model",
                #     "endpoint": "/v1/recommend"
                # },
                # "v3": {
                #     "status": "loaded" if v3_info else "not_loaded",
                #     "description": "Enhanced capability prediction model",
                #     "endpoint": "/v3/recommend",
                #     "info": v3_info
                # },
                "v4": {
                    "status": "active",
                    "description": "Two-Branch Neural Network (Intensity & Suitability)",
                    "endpoint": "/v4/recommend",
                    "features": ["Real-time State Adaptation", "RPE Prediction"]
                }
            }
        }
    except Exception as e:
        logger.error("Error getting model info: %s", str(e))
        return {
            "models": {
                # "v1": {"status": "available"},
                # "v3": {"status": "error", "error": str(e)},
                "v4": {"status": "unknown"}
            }
        }
