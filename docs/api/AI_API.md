# AI Server API Routes

**Base URL**: `http://localhost:8000`

This document outlines the API endpoints available in the AI Server (OmniMer Health Recommendation API).

## 1. System Endpoints

### Health Check

Checks if the API server is running and healthy.

- **URL**: `/health`
- **Method**: `GET`
- **Response**:
  ```json
  {
    "status": "healthy",
    "message": "OmniMer Health Recommendation API is running"
  }
  ```

### Model Information

Retrieves information about the loaded models (v1 and v3) and their status.

- **URL**: `/model/info`
- **Method**: `GET`
- **Response**:
  ```json
  {
    "models": {
      "v1": {
        "status": "available",
        "description": "Original recommendation model",
        "endpoint": "/recommend"
      },
      "v3": {
        "status": "loaded",
        "description": "Enhanced capability prediction model",
        "endpoint": "/recommend/v3",
        "info": {
          "version": "v3_enhanced",
          "training_date": "...",
          "input_features": [...],
          "num_exercises": 100,
          "test_results": {...}
        }
      }
    }
  }
  ```

---

## 2. Recommendation Endpoints

### Legacy Recommendation (v1)

Generates workout recommendations using the original Model v1. Kept for backward compatibility.

- **URL**: `/recommend`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "profile": {
      "age": 28,
      "gender": "male",
      "height_cm": 175,
      "weight_kg": 72,
      "bmi": 23.5,
      "body_fat_percentage": 15.2,
      "whr": 0.85,
      "resting_hr": 68,
      "workout_frequency_per_week": 4,
      "experience_level": "intermediate",
      "activity_level": 4,
      "max_weight_lifted_kg": 80,
      "goal_type": "hypertrophy",
      "health_status": { ... }
    },
    "top_k": 5
  }
  ```
- **Response**: Returns a list of recommended exercises based on the v1 model logic.

### Enhanced Recommendation (v3)

Generates workout recommendations using the enhanced Model v3, which utilizes capability prediction (1RM, Pace) and rule-based decoding.

- **URL**: `/recommend/v3`
- **Method**: `POST`
- **Request Body**: Same as `/recommend`, but supports additional SePA fields for auto-regulation.
  ```json
  {
    "profile": {
      // ... basic fields ...
      "mood": "Good", // "Very Bad", "Bad", "Neutral", "Good", "Very Good", "Excellent"
      "fatigue": "Low", // "Very Low", "Low", "Medium", "High", "Very High"
      "effort": "Medium", // "Very Low", "Low", "Medium", "High", "Very High"
      "goal_type": "hypertrophy"
    },
    "top_k": 5
  }
  ```
- **Response**:
  ```json
  {
    "exercises": [
      {
        "name": "Bench Press",
        "sets": [
          {
            "reps": 10,
            "kg": 62.0,
            "km": 0.0,
            "min": 0.0,
            "minRest": 2.0
          }
          // ... more sets
        ],
        "suitabilityScore": 0.92,
        "predictedAvgHR": 135,
        "predictedPeakHR": 155,
        "explanation": "Based on 1RM of 82kg, hypertrophy training at 75% intensity",
        "readinessFactor": 1.0,
        "goal": "hypertrophy"
      }
      // ... more exercises
    ],
    "suitabilityScore": 0.89,
    "predictedAvgHR": 132,
    "predictedPeakHR": 148,
    "modelVersion": "v3_enhanced",
    "goal": "hypertrophy",
    "totalExercises": 5,
    "readinessAdjustment": {
      "mood": 4.0,
      "fatigue": 2.0,
      "effort": 3.0,
      "appliedFactor": 1.0
    }
  }
  ```

### Enhanced Recommendation with Suggestions (v3)

Similar to `/recommend/v3`, but also provides goal suggestions based on the user's profile.

- **URL**: `/recommend/v3/enhanced`
- **Method**: `POST`
- **Request Body**: Same as `/recommend/v3`.
- **Response**: Includes the standard v3 response plus goal suggestions.
  ```json
  {
    // ... standard v3 response fields ...
    "goalSuggestions": [
      {
        "goal": "general_fitness",
        "reason": "Recommended for building foundation safely",
        "priority": "high"
      },
      {
        "goal": "hypertrophy",
        "reason": "Good experience level for muscle building",
        "priority": "medium"
      }
    ],
    "recommendedGoal": "hypertrophy",
    "highPriorityGoals": [
      {
        "goal": "general_fitness",
        "reason": "Recommended for building foundation safely",
        "priority": "high"
      }
    ]
  }
  ```

## 3. Data Models

### RecommendRequest

| Field     | Type    | Description                                                          |
| --------- | ------- | -------------------------------------------------------------------- |
| `profile` | Object  | User profile data containing demographics, fitness stats, and goals. |
| `top_k`   | Integer | (Optional) Number of exercises to recommend. Default: 5.             |

### User Profile Fields (Key Fields)

- **Demographics**: `age`, `gender`, `height_cm`, `weight_kg`, `bmi`
- **Fitness**: `resting_hr`, `experience_level`, `activity_level`, `max_weight_lifted_kg`
- **SePA (v3 only)**: `mood`, `fatigue`, `effort`
- **Goal**: `goal_type` (e.g., "strength", "hypertrophy", "endurance", "general_fitness")
