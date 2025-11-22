
from fastapi import FastAPI, HTTPException
from recommend_schemas import RecommendRequest
from recommend import recommend

app = FastAPI(title="OmniMer Health Recommendation API")

@app.post("/recommend")
def get_recommendation(req: RecommendRequest):
    try:
        profile = req.profile
        top_k = req.top_k or 5

        print("Data profile from backend: ", profile)
        result = recommend(profile.dict(), top_k=top_k)
        print("Result from AI: ", result)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
