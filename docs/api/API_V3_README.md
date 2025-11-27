# OmniMer Health AI Server - Model v3 API Documentation

## 🎯 Overview

This document describes the **Model v3 Enhanced Recommendation API** that implements the capability-based prediction system as outlined in the Strategy Analysis document.

### Key Improvements from v1 → v3

| Feature | Model v1 | Model v3 |
|---------|----------|----------|
| **Prediction Approach** | Direct sets/reps/weight prediction | **Capability prediction** (1RM, Pace) + Rule-based decoding |
| **Dimensions** | 8 regression outputs | **6 regression outputs** (reduced complexity) |
| **Interpretability** | Black-box | **High** - based on 1RM/Pace with clear rules |
| **Personalization** | Limited | **Advanced** - SePA integration, auto-regulation |
| **Goal Flexibility** | Fixed | **Flexible** - one model serves all goals |

---

## 🚀 API Endpoints

### 1. Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "message": "OmniMer Health Recommendation API is running"
}
```

### 2. Model Information
```http
GET /model/info
```

**Response:**
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
        "training_date": "2025-11-25",
        "input_features": ["age", "weight_kg", "height_m", "bmi", ...],
        "num_exercises": 100,
        "test_results": {...}
      }
    }
  }
}
```

### 3. Enhanced Recommendation (v3)
```http
POST /recommend/v3
Content-Type: application/json
```

### 4. Enhanced Recommendation with Goal Suggestions
```http
POST /recommend/v3/enhanced
Content-Type: application/json
```

### 5. Legacy Recommendation (v1) - Backward Compatible
```http
POST /recommend
Content-Type: application/json
```

---

## 📊 Request Schema

All v3 endpoints accept the same request format:

```json
{
  "profile": {
    // Basic demographics
    "age": 28,
    "gender": "male",
    "height_cm": 175,
    "weight_kg": 72,
    "bmi": 23.5,
    "body_fat_percentage": 15.2,
    "whr": 0.85,

    // Fitness parameters
    "resting_hr": 68,
    "workout_frequency_per_week": 4,
    "experience_level": "intermediate",  // "beginner", "intermediate", "advanced"
    "activity_level": 4,
    "max_weight_lifted_kg": 80,

    // SePA (Self-Perceived Assessment) - NEW in v3
    "mood": "Good",           // "Very Bad", "Bad", "Neutral", "Good", "Very Good", "Excellent"
    "fatigue": "Low",         // "Very Low", "Low", "Medium", "High", "Very High"
    "effort": "Medium",       // "Very Low", "Low", "Medium", "High", "Very High"

    // Goals
    "goal_type": "hypertrophy",  // "strength", "hypertrophy", "endurance", "general_fitness"
    "target_metric": {...},

    // Health status
    "health_status": {
      "knownConditions": [],
      "painLocations": [],
      "jointIssues": [],
      "injuries": [],
      "abnormalities": [],
      "notes": "Generally healthy, looking to build muscle mass"
    }
  },
  "top_k": 5  // Number of exercises to recommend (default: 5)
}
```

---

## 🎯 Response Schema

### Standard v3 Response

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
        },
        {
          "reps": 10,
          "kg": 62.0,
          "km": 0.0,
          "min": 0.0,
          "minRest": 2.0
        },
        {
          "reps": 8,
          "kg": 65.0,
          "km": 0.0,
          "min": 0.0,
          "minRest": 2.5
        }
      ],
      "suitabilityScore": 0.92,
      "predictedAvgHR": 135,
      "predictedPeakHR": 155,
      "explanation": "Based on 1RM of 82kg, hypertrophy training at 75% intensity",
      "readinessFactor": 1.0,
      "goal": "hypertrophy"
    }
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

### Enhanced v3 Response (with suggestions)

```json
{
  // ... same as standard response ...
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

---

## 🏃‍♂️ Exercise Types

### Strength Exercises
```json
{
  "name": "Squat",
  "sets": [
    {
      "reps": 12,      // Number of repetitions
      "kg": 80.5,      // Weight in kilograms
      "km": 0.0,       // Distance (0 for strength)
      "min": 0.0,      // Duration (0 for strength)
      "minRest": 2.0   // Rest time in minutes
    }
  ],
  "exercise_type": "strength"
}
```

### Cardio Exercises
```json
{
  "name": "Treadmill Running",
  "sets": [
    {
      "reps": 0,           // 0 for cardio
      "kg": 0.0,           // 0 for cardio
      "km": 5.0,           // Distance in kilometers
      "min": 30.0,         // Duration in minutes
      "minRest": 2.0       // Rest time between intervals
    }
  ],
  "exercise_type": "cardio"
}
```

### HIIT Exercises
```json
{
  "name": "HIIT Cycling",
  "sets": [
    {
      "reps": 0,
      "kg": 0.0,
      "km": 1.2,      // Distance for high intensity interval
      "min": 2.0,      // Duration for high intensity interval
      "minRest": 1.0   // Recovery period
    },
    {
      "reps": 0,
      "kg": 0.0,
      "km": 0.8,      // Distance for low intensity interval
      "min": 3.0,      // Duration for low intensity interval
      "minRest": 0.5
    }
  ],
  "exercise_type": "cardio"
}
```

---

## 🔧 Goal-Based Decoding Rules

Model v3 predicts capabilities (1RM, Pace) and uses rule-based decoding:

### Strength Training
- **Intensity:** 85-95% of 1RM
- **Reps:** 5-15
- **Sets:** 1-5
- **Rest:** 3-5 minutes

### Hypertrophy Training
- **Intensity:** 70-80% of 1RM
- **Reps:** 8-20
- **Sets:** 1-5
- **Rest:** 1-2 minutes

### Endurance Training
- **Intensity:** 50-60% of 1RM
- **Reps:** 10-30
- **Sets:** 1-5
- **Rest:** 30-60 seconds

### General Fitness
- **Intensity:** 60-75% of 1RM
- **Reps:** 10-30
- **Sets:** 1-5
- **Rest:** 1-2 minutes

---

## 🧠 Auto-Regulation (SePA Integration)

Model v3 adjusts workout intensity based on daily readiness:

### Readiness Factor Calculation
```
Readiness Score = (Mood × 0.4) + ((6 - Fatigue) × 0.4) + (Effort × 0.2)
```

### Adjustment Rules
- **Readiness ≥ 4.5:** Factor = 1.05 (Increase load - Progressive Overload)
- **Readiness ≥ 3.5:** Factor = 1.0 (Normal training)
- **Readiness ≥ 2.5:** Factor = 0.9 (Reduce load slightly)
- **Readiness < 2.5:** Factor = 0.8 (Reduce load significantly)

### Example
If user predicts 1RM = 100kg and Readiness Factor = 0.9:
- Working weight = 100kg × 0.75 × 0.9 = 67.5kg (vs 75kg normally)

---

## 📝 Example Usage

### Example 1: Intermediate User - Hypertrophy Goal

**Request:**
```bash
curl -X POST "http://localhost:8000/recommend/v3" \
  -H "Content-Type: application/json" \
  -d @test_v3_request.json
```

**Response Highlights:**
- Predicts 1RM: ~82kg for compound lifts
- Generates 3-4 sets with 8-12 reps at 70-80% intensity
- Adjusts based on "Good" mood, "Low" fatigue
- Returns progressive overload within session

### Example 2: Beginner User - General Fitness

**Request:**
```bash
curl -X POST "http://localhost:8000/recommend/v3/enhanced" \
  -H "Content-Type: application/json" \
  -d @test_v3_beginner.json
```

**Response Highlights:**
- Suggests "general_fitness" goal (high priority)
- Lower intensity (50-60% estimated 1RM)
- More rest between sets
- Cardio focus due to high BMI (31.2)

### Example 3: Advanced User - Strength Goal

**Request:**
```bash
curl -X POST "http://localhost:8000/recommend/v3" \
  -H "Content-Type: application/json" \
  -d @test_v3_strength.json
```

**Response Highlights:**
- Predicts high 1RM: ~120kg for main lifts
- High intensity (85-95% 1RM)
- Low reps (3-5), high sets (4-5)
- Long rest periods (3-5 minutes)

---

## 🔍 Error Handling

### Validation Errors (400)
```json
{
  "detail": "Profile validation failed: Missing required fields: age, weight_kg"
}
```

### Model Loading Errors (500)
```json
{
  "detail": "Model v3 not loaded. Call load_model_v3() first."
}
```

### Processing Errors (500)
```json
{
  "detail": "Error in v3 recommendation: Invalid numeric values"
}
```

---

## 🚀 Quick Start

### 1. Start the Server
```bash
cd app
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Test Health Check
```bash
curl http://localhost:8000/health
```

### 3. Test Model Info
```bash
curl http://localhost:8000/model/info
```

### 4. Test v3 Recommendation
```bash
curl -X POST "http://localhost:8000/recommend/v3" \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "age": 30,
      "gender": "male",
      "height_cm": 175,
      "weight_kg": 75,
      "bmi": 24.5,
      "resting_hr": 70,
      "experience_level": "intermediate",
      "goal_type": "hypertrophy"
    },
    "top_k": 3
  }'
```

---

## 🎯 Key Benefits of Model v3

1. **Physiologically Valid:** Eliminates impossible combinations (e.g., 100kg × 50 reps)
2. **Explainable:** Clear reasoning based on 1RM and training principles
3. **Adaptive:** Adjusts to daily readiness and fatigue
4. **Flexible:** One model serves all training goals
5. **Safe:** Incorporates user's historical limits and safety caps
6. **Comprehensive:** Supports both strength and cardio training
7. **Personalized:** Goal suggestions based on user profile

---

## 📊 Performance Metrics

Based on training results (`meta_v3.json`):
- **1RM Prediction RMSE:** 31.9kg
- **1RM Prediction R²:** 0.38
- **Suitability Scoring:** Improved consistency over v1
- **Readiness Factor:** Effective auto-regulation
- **Physiological Validity:** >95% (estimated)

---

## 🔧 Development Notes

### File Structure
```
app/
├── main.py              # FastAPI application and endpoints
├── recommend_v3.py      # v3 recommendation logic
├── model_v3.py          # Model v3 architecture and loading
├── preprocess_v3.py     # v3 preprocessing and feature engineering
├── decoders.py          # Rule-based workout decoding
├── recommend.py         # Legacy v1 recommendation (backward compatibility)
├── model.py             # Legacy v1 model
├── preprocess.py        # Legacy v1 preprocessing
├── recommend_schemas.py # Pydantic schemas (shared)
├── test_v3_request.json # Test cases
├── test_v3_beginner.json
├── test_v3_strength.json
└── API_V3_README.md     # This documentation
```

### Dependencies
- FastAPI
- PyTorch
- Scikit-learn
- Pandas
- NumPy
- Uvicorn

### Model Artifacts Location
```
../model/src/v3/model/
├── best_v3.pt           # Trained model weights
├── meta_v3.json         # Model metadata and configuration
├── decoding_rules.json  # Workout parameter rules (optional)
└── preprocessor_v3.joblib # Feature preprocessing pipeline
```