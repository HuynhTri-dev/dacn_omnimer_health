import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/workout_frequency_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';

abstract class ChartRepositoryAbs {
  Future<ApiResponse<List<WorkoutFrequencyEntity>>> getWorkoutFrequency();
  Future<ApiResponse<List<CaloriesBurnedEntity>>> getCaloriesBurned();
  Future<ApiResponse<List<MuscleDistributionEntity>>> getMuscleDistribution();
  Future<ApiResponse<List<GoalProgressEntity>>> getGoalProgress();
  Future<ApiResponse<List<WeightProgressEntity>>> getWeightProgress();
}
