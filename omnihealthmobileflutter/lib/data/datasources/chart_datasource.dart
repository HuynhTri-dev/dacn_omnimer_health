import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/chart/workout_frequency_model.dart';
import 'package:omnihealthmobileflutter/data/models/chart/calories_burned_model.dart';
import 'package:omnihealthmobileflutter/data/models/chart/muscle_distribution_model.dart';
import 'package:omnihealthmobileflutter/data/models/chart/goal_progress_model.dart';
import 'package:omnihealthmobileflutter/data/models/chart/weight_progress_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

class ChartDataSource {
  final ApiClient apiClient;

  ChartDataSource({required this.apiClient});

  Future<ApiResponse<List<WorkoutFrequencyModel>>> getWorkoutFrequency() async {
    try {
      final response = await apiClient.get<List<WorkoutFrequencyModel>>(
        Endpoints.getWorkoutFrequency,
        parser: (data) {
          if (data is List) {
            return data.map((e) => WorkoutFrequencyModel.fromJson(e)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      logger.e('[ChartDataSource] getWorkoutFrequency error: $e');
      return ApiResponse<List<WorkoutFrequencyModel>>.error(
        "Failed to get workout frequency: ${e.toString()}",
      );
    }
  }

  Future<ApiResponse<List<CaloriesBurnedModel>>> getCaloriesBurned() async {
    try {
      final response = await apiClient.get<List<CaloriesBurnedModel>>(
        Endpoints.getCaloriesBurned,
        parser: (data) {
          if (data is List) {
            return data.map((e) => CaloriesBurnedModel.fromJson(e)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      logger.e('[ChartDataSource] getCaloriesBurned error: $e');
      return ApiResponse<List<CaloriesBurnedModel>>.error(
        "Failed to get calories burned: ${e.toString()}",
      );
    }
  }

  Future<ApiResponse<List<MuscleDistributionModel>>>
  getMuscleDistribution() async {
    try {
      final response = await apiClient.get<List<MuscleDistributionModel>>(
        Endpoints.getMuscleDistribution,
        parser: (data) {
          if (data is List) {
            return data
                .map((e) => MuscleDistributionModel.fromJson(e))
                .toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      logger.e('[ChartDataSource] getMuscleDistribution error: $e');
      return ApiResponse<List<MuscleDistributionModel>>.error(
        "Failed to get muscle distribution: ${e.toString()}",
      );
    }
  }

  Future<ApiResponse<List<GoalProgressModel>>> getGoalProgress() async {
    try {
      final response = await apiClient.get<List<GoalProgressModel>>(
        Endpoints.getGoalProgress,
        parser: (data) {
          if (data is List) {
            return data.map((e) => GoalProgressModel.fromJson(e)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      logger.e('[ChartDataSource] getGoalProgress error: $e');
      return ApiResponse<List<GoalProgressModel>>.error(
        "Failed to get goal progress: ${e.toString()}",
      );
    }
  }

  Future<ApiResponse<List<WeightProgressModel>>> getWeightProgress() async {
    try {
      final response = await apiClient.get<List<WeightProgressModel>>(
        Endpoints.getWeightProgress,
        parser: (data) {
          if (data is List) {
            return data.map((e) => WeightProgressModel.fromJson(e)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      logger.e('[ChartDataSource] getWeightProgress error: $e');
      return ApiResponse<List<WeightProgressModel>>.error(
        "Failed to get weight progress: ${e.toString()}",
      );
    }
  }
}
