# 3T-FIT Data Processing Pipeline

This directory contains the data processing pipeline for the 3T-FIT AI Recommendation System. It combines and processes raw exercise tracking data into a clean, normalized dataset ready for machine learning training.

## Files Overview

### Core Processing Scripts

- **`data_processor.py`** - Main data processing pipeline
  - Combines Kaggle synthetic data (10,000 records) with real-world data (200 records)
  - Performs comprehensive data cleaning and validation
  - Calculates derived features for ML training
  - Implements enhanced suitability scoring algorithm
  - Outputs normalized dataset ready for training

- **`dataset_loader.py`** - Utility for loading and using the processed dataset
  - Easy loading of final dataset
  - Train/test splitting for ML models
  - Exercise recommendation filtering
  - Export to ML-ready formats

### Input Data Files

- **`../kaggle_dataset.xlsx`** - Synthetic gym exercise tracking data (10,000 records)
- **`../real_dataset.xlsx`** - Real-world collected data (200 records)

### Output Files

- **`../final_dataset.xlsx`** - Combined, cleaned, and normalized dataset (10,200 records, 38 features)
- **`../final_dataset_summary.txt`** - Summary statistics and data processing report
- **`../training_data/`** - ML-ready training and testing data splits

## Data Processing Pipeline

### 1. Data Loading and Validation
- Loads both Kaggle and real datasets
- Validates data types and ranges based on exercise science standards
- Identifies and handles missing values

### 2. Data Cleaning
- **Range Validation**: Ensures all values fall within physiologically valid ranges
- **Duplicate Removal**: Eliminates duplicate records
- **Physiological Validation**: Fixes inconsistent relationships (e.g., max HR < avg HR)
- **BMI Consistency**: Ensures BMI matches height and weight calculations

### 3. Feature Engineering
Creates derived features for the two-branch neural network architecture:

#### Resistance Training Features
- **`resistance_intensity`**: Effort relative to estimated 1RM
- **`volume_load`**: Total training volume (intensity × duration)

#### Cardio Training Features
- **`cardio_intensity`**: Heart rate zone (avg_hr / max_hr)
- **`calorie_efficiency`**: Calories burned per minute

#### Recovery and Performance Features
- **`rest_density`**: Ratio of rest time to total time
- **`hr_reserve`**: Heart rate reserve percentage

### 4. Enhanced Suitability Scoring

Implements the formula from the main README:

**Suitability Score = (0.4 × Psychological) + (0.3 × Physiological) + (0.3 × Performance)**

#### Psychological Component (40%)
- Based on mood (higher is better) and fatigue (lower is better)
- Formula: `(norm_mood × 0.7) + ((1 - norm_fatigue) × 0.3)`

#### Physiological Component (30%)
- Based on heart rate training zones
- Optimal range: 70-80% of maximum heart rate
- Formula: `1 - |hr_ratio - 0.75|`

#### Performance Component (30%)
- Based on calorie efficiency (calories per minute)
- Higher efficiency = better performance

### 5. Data Normalization
- **MinMax Scaling**: Normalizes all numerical features to [0, 1] range
- **Label Encoding**: Encodes categorical variables (exercise names, workout types, locations)

## Final Dataset Structure

### Total Records: 10,200
- **Kaggle synthetic data**: 10,000 records (98.0%)
- **Real-world data**: 200 records (2.0%)

### Features: 38 columns

#### Original Features (26)
- User demographics: age, height, weight, BMI, body fat percentage
- Exercise metrics: duration, heart rates, calories, intensity
- Subjective ratings: fatigue, effort, mood
- Exercise metadata: type, location, equipment requirements

#### Derived Features (6)
- Resistance intensity, cardio intensity, volume load
- Rest density, heart rate reserve, calorie efficiency

#### Target Variables (2)
- **`enhanced_suitability`**: Continuous score (0.0 - 1.0) for regression
- **`is_suitable`**: Binary label (0/1) for classification (threshold = 0.7)

#### Encoded Features (4)
- Label-encoded versions of categorical variables

## Dataset Statistics

### Suitability Score Distribution
- **Mean**: 0.805
- **Standard Deviation**: 0.078
- **Minimum**: 0.560
- **Maximum**: 1.000

### Classification Balance
- **Suitable (≥0.7)**: 9,357 records (91.7%)
- **Not Suitable (<0.7)**: 843 records (8.3%)

### Exercise Variety
- **Unique exercises**: 820
- **Workout types**: Strength, Cardio, HIIT, Flexibility, Sports

## Usage Examples

### Basic Data Loading
```python
from src.dataset_loader import DatasetLoader

# Initialize loader
loader = DatasetLoader("../final_dataset.xlsx")

# Load dataset
data = loader.load_dataset()

# Get statistics
stats = loader.get_dataset_statistics()
```

### ML Training Preparation
```python
# Get train/test split
splits = loader.get_train_test_split(test_size=0.2)

# Access training data
X_train = splits['X_train']
y_regression = splits['y_reg_train']  # Enhanced suitability
y_classification = splits['y_cls_train']  # Binary suitable/not
```

### Exercise Recommendations
```python
# Get top suitable exercises
top_exercises = loader.get_suitable_exercises(limit=10)

# Get personalized recommendations
recommendations = loader.get_exercise_recommendations(
    workout_type='Strength',
    min_duration=5,
    max_duration=30,
    min_suitability=0.8,
    limit=5
)
```

### Save ML-Ready Data
```python
# Save training data in standard format
loader.save_training_data(output_dir="../training_data")
```

## Data Quality Assurance

### Validation Rules Applied
- **Age**: 10-80 years
- **Height**: 1.2-2.3 meters
- **Weight**: 30-200 kg
- **BMI**: 15-40
- **Body Fat**: 5-50%
- **Resting HR**: 40-100 bpm
- **Exercise HR**: 50-220 bpm
- **Duration**: 0.5-180 minutes
- **Calories**: 10-2000 per session

### Out-of-Range Values Fixed: 12,524 total
- BMI inconsistencies: 96 records
- Heart rate inversions: 96 records
- Various physiological range violations: 12,332 records

## Integration with AI System

This processed dataset is designed to work with the **Two-Branch Neural Network** architecture described in the main README:

### Branch A: Intensity Prediction
- **Input**: User features + Exercise features + Derived intensity features
- **Output**: Predicted RPE (Rate of Perceived Exertion)

### Branch B: Suitability Prediction
- **Input**: Predicted RPE + User health status + Exercise constraints
- **Output**: Suitability score (0.0 - 1.0)

The enhanced suitability scores calculated here can serve as **ground truth labels** for training both branches of the neural network.

## Next Steps

1. **Model Training**: Use the processed data to train the two-branch neural network
2. **Validation**: Test model performance on the held-out test set (2,040 records)
3. **Hyperparameter Tuning**: Optimize model architecture and training parameters
4. **Deployment**: Integrate trained model into the 3T-FIT AI recommendation service

## Technical Requirements

- Python 3.8+
- pandas, numpy
- scikit-learn
- openpyxl (for Excel file handling)

The pipeline is designed to be **reproducible** and **extensible** for future data updates and model improvements.