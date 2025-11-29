"""
Decoders for Model v3 - Convert predicted capabilities to workout parameters
Based on Strategy_Analysis.md principles: 1RM/Pace prediction + Rule-based decoding
"""

import json
import numpy as np
from typing import Dict, List, Tuple, Optional
import logging

logger = logging.getLogger(__name__)

class WorkoutDecoder:
    """
    Convert model v3 predictions (1RM, Pace, HR, Readiness)
    into detailed workout parameters using rule-based decoding
    """

    def __init__(self, meta_v3_path: str = None):
        """Initialize decoder with workout goals configuration from meta_v3.json"""
        if meta_v3_path is None:
            meta_v3_path = "../../model/src/v3/model/meta_v3.json"

        try:
            with open(meta_v3_path, 'r', encoding='utf-8') as f:
                meta_v3 = json.load(f)

            self.workout_goals = meta_v3.get('workout_goals', {})
            self.sepa_mapping = meta_v3.get('sepa_mapping', {})

            logger.info(f"Loaded workout goals: {list(self.workout_goals.keys())}")

        except Exception as e:
            logger.error(f"Failed to load meta_v3.json: {e}")
            # Fallback to default goals
            self.workout_goals = self._get_default_goals()
            self.sepa_mapping = self._get_default_sepa()

    def _get_default_goals(self) -> Dict:
        """Fallback workout goals configuration"""
        return {
            "strength": {
                "intensity_percent": [0.85, 0.95],
                "rep_range": [5, 15],
                "sets_range": [1, 5],
                "rest_minutes": [3, 5]
            },
            "hypertrophy": {
                "intensity_percent": [0.7, 0.8],
                "rep_range": [8, 20],
                "sets_range": [1, 5],
                "rest_minutes": [1, 2]
            },
            "endurance": {
                "intensity_percent": [0.5, 0.6],
                "rep_range": [10, 30],
                "sets_range": [1, 5],
                "rest_minutes": [0.5, 1]
            }
        }

    def _get_default_sepa(self) -> Dict:
        """Fallback SEPA mapping"""
        return {
            "mood": {"Very Bad": 1, "Bad": 2, "Neutral": 3, "Good": 4, "Very Good": 5},
            "fatigue": {"Very Low": 1, "Low": 2, "Medium": 3, "High": 4, "Very High": 5},
            "effort": {"Very Low": 1, "Low": 2, "Medium": 3, "High": 4, "Very High": 5}
        }

    def calculate_readiness_factor(self, mood: float, fatigue: float, effort: float) -> float:
        """
        Calculate auto-regulation factor based on SePA scores

        Args:
            mood: 1-5 scale (higher = better)
            fatigue: 1-5 scale (higher = more fatigued)
            effort: 1-5 scale (higher = more effort)

        Returns:
            float: 0.8 (reduce load) to 1.05 (progressive overload)
        """
        # Calculate readiness score (higher = more ready to train)
        readiness_score = (mood * 0.4) + ((6 - fatigue) * 0.4) + (effort * 0.2)

        # Map readiness score to adjustment factor
        if readiness_score >= 4.5:
            return 1.05  # Excellent readiness - can increase load
        elif readiness_score >= 3.5:
            return 1.0   # Good readiness - normal training
        elif readiness_score >= 2.5:
            return 0.9   # Fair readiness - reduce load slightly
        else:
            return 0.8   # Poor readiness - reduce load significantly

    def decode_strength_exercise(
        self,
        predicted_1rm: float,
        goal: str = "hypertrophy",
        readiness_factor: float = 1.0,
        max_weight_lifted: Optional[float] = None
    ) -> Dict:
        """
        Convert predicted 1RM to sets/reps/weight based on goal

        Args:
            predicted_1rm: Model's 1RM prediction in kg
            goal: "strength", "hypertrophy", "endurance", or "general_fitness"
            readiness_factor: Auto-regulation adjustment (0.8-1.05)
            max_weight_lifted: User's historical max for safety cap

        Returns:
            Dict with sets, reps, weight, rest recommendations
        """
        if goal not in self.workout_goals:
            goal = "hypertrophy"  # Default fallback

        goal_config = self.workout_goals[goal]

        # Calculate intensity percentage (middle of range for stability)
        intensity_percent = np.mean(goal_config["intensity_percent"])

        # Calculate working weight
        working_weight = predicted_1rm * intensity_percent * readiness_factor

        # Apply safety cap if user has historical max
        if max_weight_lifted and max_weight_lifted > 0:
            working_weight = min(working_weight, max_weight_lifted * 0.95)

        # Calculate reps and sets (middle of ranges)
        reps = int(np.mean(goal_config["rep_range"]))
        sets = int(np.mean(goal_config["sets_range"]))

        # Calculate rest time
        rest_min = np.mean(goal_config["rest_minutes"])

        # Add some variation to sets (progressive overload within session)
        sets_config = []
        for i in range(sets):
            # Slightly increase weight for later sets
            set_weight = working_weight * (1 + 0.02 * i) if i < 2 else working_weight * 1.04
            # Slightly reduce reps for later sets
            set_reps = max(reps - i, reps - 1) if i < 2 else reps - 2

            sets_config.append({
                "reps": max(1, int(set_reps)),
                "kg": round(set_weight, 1),
                "km": 0.0,
                "min": 0.0,
                "minRest": round(rest_min + (0.5 * i), 1)  # Slightly more rest for later sets
            })

        return {
            "sets": sets_config,
            "working_weight": round(working_weight, 1),
            "intensity_percent": round(intensity_percent * 100, 1),
            "explanation": f"Based on 1RM of {predicted_1rm:.1f}kg, {goal} training at {intensity_percent*100:.0f}% intensity"
        }

    def decode_cardio_exercise(
        self,
        predicted_pace: float,
        goal: str = "general_fitness",
        duration_min: float = 30.0,
        readiness_factor: float = 1.0
    ) -> Dict:
        """
        Convert predicted pace to cardio workout parameters

        Args:
            predicted_pace: Model's pace prediction in km/h
            goal: "fat_loss", "cardio", "hiit", or "general_fitness"
            duration_min: Target workout duration
            readiness_factor: Auto-regulation adjustment

        Returns:
            Dict with cardio parameters
        """
        # Adjust pace based on readiness and goal
        if goal == "hiit":
            # HIIT: intervals of high and low intensity
            high_pace = predicted_pace * 1.2 * readiness_factor
            low_pace = predicted_pace * 0.6 * readiness_factor

            interval_duration = duration_min / 6  # 6 intervals (3 high, 3 low)
            intervals = []

            for i in range(6):
                is_high = i % 2 == 0
                pace = high_pace if is_high else low_pace
                intensity = "High" if is_high else "Low"

                intervals.append({
                    "pace_kmh": round(pace, 1),
                    "duration_min": round(interval_duration, 1),
                    "intensity": intensity,
                    "minRest": 1.0 if is_high else 0.5
                })

            return {
                "intervals": intervals,
                "total_duration_min": duration_min,
                "avg_pace_kmh": round(np.mean([high_pace, low_pace]), 1),
                "explanation": f"HIIT workout alternating between {high_pace:.1f} km/h and {low_pace:.1f} km/h"
            }

        else:
            # Steady state cardio
            if goal == "fat_loss":
                target_pace = predicted_pace * 0.7 * readiness_factor  # Lower intensity for fat burning
                zone = "Zone 2"
            elif goal == "cardio":
                target_pace = predicted_pace * 0.85 * readiness_factor  # Moderate intensity
                zone = "Zone 3"
            else:  # general_fitness
                target_pace = predicted_pace * 0.8 * readiness_factor
                zone = "Zone 2-3"

            # Calculate distance
            distance_km = (target_pace * duration_min) / 60

            return {
                "pace_kmh": round(target_pace, 1),
                "duration_min": duration_min,
                "distance_km": round(distance_km, 2),
                "hr_zone": zone,
                "explanation": f"Steady {zone} cardio at {target_pace:.1f} km/h for {duration_min} minutes"
            }

    def is_cardio_exercise(self, exercise_name: str) -> bool:
        """Check if exercise is cardio-based"""
        name_lower = exercise_name.lower()
        cardio_keywords = [
            "run", "jog", "bike", "cycle", "row", "swim",
            "elliptical", "walking", "cycling", "treadmill",
            "stair", "step", "cardio"
        ]
        return any(keyword in name_lower for keyword in cardio_keywords)

    def decode_exercise(
        self,
        exercise_name: str,
        predicted_1rm: float,
        predicted_pace: float,
        predicted_avg_hr: int,
        predicted_peak_hr: int,
        predicted_duration: float,
        predicted_rest: float,
        goal: str = "hypertrophy",
        mood: float = 3.0,
        fatigue: float = 3.0,
        effort: float = 3.0,
        max_weight_lifted: Optional[float] = None,
        target_duration: float = 30.0
    ) -> Dict:
        """
        Main decoder function - route to appropriate decoder based on exercise type

        Args:
            exercise_name: Name of the exercise
            predicted_1rm: Model's 1RM prediction (kg)
            predicted_pace: Model's pace prediction (km/h)
            predicted_avg_hr: Predicted average heart rate
            predicted_peak_hr: Predicted peak heart rate
            predicted_duration: Predicted duration (minutes)
            predicted_rest: Predicted rest time (minutes)
            goal: Workout goal
            mood, fatigue, effort: SePA scores (1-5 scale)
            max_weight_lifted: User's historical max weight
            target_duration: Target duration for cardio exercises

        Returns:
            Dict with decoded workout parameters
        """
        # Calculate readiness factor
        readiness_factor = self.calculate_readiness_factor(mood, fatigue, effort)

        if self.is_cardio_exercise(exercise_name):
            result = self.decode_cardio_exercise(
                predicted_pace, goal, target_duration, readiness_factor
            )
            result["predictedAvgHR"] = predicted_avg_hr
            result["predictedPeakHR"] = predicted_peak_hr
        else:
            result = self.decode_strength_exercise(
                predicted_1rm, goal, readiness_factor, max_weight_lifted
            )
            result["predictedAvgHR"] = predicted_avg_hr
            result["predictedPeakHR"] = predicted_peak_hr

        result["exercise_type"] = "cardio" if self.is_cardio_exercise(exercise_name) else "strength"
        result["readiness_factor"] = round(readiness_factor, 3)
        result["goal"] = goal

        return result