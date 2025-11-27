# V4 Model Test Data

## Overview
Comprehensive test dataset created for V4 two-branch model evaluation, containing 2,000 synthetic samples with realistic workout data, user profiles, and SePA features.

## Generated Files

### Main Dataset
- **`enhanced_gym_member_exercise_tracking_v4_test.xlsx`** (2,000 samples, 50 features)
- **`enhanced_gym_member_exercise_tracking_v4_test_sample.xlsx`** (100 samples for quick testing)

### Metadata & Specifications
- **`v4_test_feature_specifications.json`** - Complete feature mapping and dataset statistics
- **`v4_test_generation_report.json`** - Detailed generation report with data characteristics
- **`TEST_DATA_README.md`** - This documentation file

## Data Structure

### User Profile Features (Branch A)
- `age` (18-65 years)
- `weight_kg` (45-150 kg)
- `height_m` (1.45-2.10 m)
- `bmi` (calculated)
- `experience_level` (1-5 scale)
- `workout_frequency` (1-7 days/week)
- `resting_heartrate` (50-90 bpm)
- `fitness_goal` (strength/hypertrophy/endurance/general_fitness)
- `estimated_1rm` (20-250 kg)
- `max_pace` (0.5-2.0 units)

### SePA Features (Subjective Physical Activity)
- `mood_numeric` (1-5: Very Bad to Excellent)
- `fatigue_numeric` (1-5: Not at all to Extremely)
- `effort_numeric` (1-5: Very Easy to Very Hard)
- `readiness_factor_v4` (0.5-1.5: Very Low to Very High)
- `sepa_composite` (normalized composite score)

### Exercise Information
- `exercise_name` (50+ different exercises)
- `exercise_type` (compound/isolation/cardio/bodyweight/plyometric)
- `muscle_group` (8 major muscle groups)
- `difficulty_level` (1-5 scale)
- `workout_data` (sets x reps x weight format)
- `duration_min` (exercise duration)
- `avg_hr` / `max_hr` (heart rate metrics)
- `calories` (estimated calories burned)

### Intensity Coefficients (V4 Specific)
- `resistance_intensity` (0-2 scale)
- `cardio_intensity` (0-1.5 scale)
- `volume_load` (0-1 normalized)
- `rest_density` (0-1 ratio)
- `tempo_factor` (0.5-1.5 scale)
- `metabolic_stress` (0-1 scale)

### Target Variables
- `target_overall_intensity` (0-1 scale) - Primary Branch A target
- `target_suitability` (0-1 scale) - Primary Branch B target
- `target_readiness_v4` (0.5-1.5 scale) - Auxiliary target
- `target_1rm_enhanced` (20-250 kg) - Performance target
- `target_performance_class_encoded` (0-4) - Classification target

## Dataset Statistics

### Distribution
- **Fitness Goals**: general_fitness (572), hypertrophy (519), strength (491), endurance (418)
- **Exercise Types**: compound (604), bodyweight (572), isolation (406), cardio (333), plyometric (85)
- **Muscle Groups**: legs (670), chest (400), core (289), back (202), full_body (175), shoulders (146), arms (118)

### Target Variable Ranges
- **Overall Intensity**: 0.050 - 0.988 (mean: 0.294)
- **Suitability**: 0.000 - 1.000 (mean: 0.849)
- **Readiness Factor**: 0.500 - 1.124 (mean: 0.625)

### SePA Distributions
- **Mood**: Centered around 3.3 (Good)
- **Fatigue**: Centered around 3.4 (Moderate to High)
- **Effort**: Centered around 3.6 (Moderate to Hard)

## V4 Model Compatibility

### Branch A (Intensity Prediction)
✅ All required user profile features present
✅ Exercise information properly encoded
✅ Target intensity variables in correct range
✅ Intensity coefficients calculated according to V4 specifications

### Branch B (Suitability Prediction)
✅ Comprehensive feature set (14+ features)
✅ SePA features properly normalized
✅ Performance metrics included
✅ Target suitability scores in 0-1 range

### Multi-Task Learning
✅ Auxiliary targets (readiness, performance) available
✅ All features compatible with PyTorch tensor conversion
✅ Data preprocessing matches V4Dataset expectations
✅ No missing values or data quality issues

## Usage Instructions

### For V4 Model Evaluation
```bash
cd D:\dacn_omnimer_health\3T-FIT\ai_server\model\src\v4
python evaluate_v4_model.py --data data/enhanced_gym_member_exercise_tracking_v4_test.xlsx
```

### For Quick Testing (100 samples)
```bash
python evaluate_v4_model.py --data data/enhanced_gym_member_exercise_tracking_v4_test_sample.xlsx
```

### Custom Testing Parameters
```bash
python evaluate_v4_model.py \
    --model ./artifacts_v4/v4_two_branch_model.pt \
    --data data/enhanced_gym_member_exercise_tracking_v4_test.xlsx \
    --artifacts ./evaluation_artifacts \
    --num_workout_samples 200
```

## Data Quality Assurances

### Validation Checks
- ✅ 2,000 complete samples (no missing values)
- ✅ All variables in expected ranges
- ✅ Realistic exercise-to-goal matching
- ✅ Proper SePA score distributions
- ✅ Physiologically plausible parameters
- ✅ Balanced fitness goal representation
- ✅ Comprehensive exercise variety

### Statistical Properties
- **Age**: Normal distribution around 30-45 years
- **Weight/BMI**: Correlated with height and fitness goals
- **Experience**: Progressive with age and workout frequency
- **SePA**: Realistic distributions based on exercise intensity
- **Targets**: Appropriate ranges for V4 model training

## Integration with Existing V4 Pipeline

### Feature Specifications
The generated dataset includes all features specified in `v4_feature_specifications.json`:
- 6 intensity branch features
- 14 suitability branch features
- 8 shared features
- 7 target variables

### Model Architecture Compatibility
- Branch A: 12+ input features for intensity prediction
- Branch B: 20+ input features for suitability prediction
- Shared: Multi-task learning with auxiliary targets
- Outputs: 4 primary outputs as specified in V4 architecture

## Notes for Model Evaluation

1. **Data Split**: Use appropriate train/validation/test splits for evaluation
2. **Normalization**: V4Dataset handles feature normalization automatically
3. **Target Scaling**: All targets are in optimal ranges for model training
4. **SePA Integration**: Features properly integrated for personalized predictions
5. **Exercise Diversity**: Broad coverage of exercise types and muscle groups

## Generation Details

- **Generator Version**: V4.0
- **Random Seeds**: 42-46 for reproducibility
- **Generation Date**: 2025-11-27
- **Total Processing Time**: ~30 seconds for 2,000 samples

---

**This dataset is ready for comprehensive V4 model evaluation and should provide robust performance metrics across all model branches and multi-task learning objectives.**