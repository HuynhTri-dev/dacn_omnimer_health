import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/chart_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/chart_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/workout_frequency_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';

class ChartRepositoryImpl implements ChartRepositoryAbs {
  final ChartDataSource chartDataSource;

  ChartRepositoryImpl({required this.chartDataSource});

  @override
  Future<ApiResponse<List<WorkoutFrequencyEntity>>>
  getWorkoutFrequency() async {
    final response = await chartDataSource.getWorkoutFrequency();

    if (response.success && response.data != null) {
      final entities = response.data!.map((e) => e.toEntity()).toList();
      return ApiResponse.success(entities, message: response.message);
    } else {
      return ApiResponse.error(response.message, error: response.error);
    }
  }

  @override
  Future<ApiResponse<List<CaloriesBurnedEntity>>> getCaloriesBurned() async {
    final response = await chartDataSource.getCaloriesBurned();

    if (response.success && response.data != null) {
      final entities = response.data!.map((e) => e.toEntity()).toList();
      return ApiResponse.success(entities, message: response.message);
    } else {
      return ApiResponse.error(response.message, error: response.error);
    }
  }

  @override
  Future<ApiResponse<List<MuscleDistributionEntity>>>
  getMuscleDistribution() async {
    final response = await chartDataSource.getMuscleDistribution();

    if (response.success && response.data != null) {
      final entities = response.data!.map((e) => e.toEntity()).toList();
      return ApiResponse.success(entities, message: response.message);
    } else {
      return ApiResponse.error(response.message, error: response.error);
    }
  }

  @override
  Future<ApiResponse<List<GoalProgressEntity>>> getGoalProgress() async {
    final response = await chartDataSource.getGoalProgress();

    if (response.success && response.data != null) {
      final entities = response.data!.map((e) => e.toEntity()).toList();
      return ApiResponse.success(entities, message: response.message);
    } else {
      return ApiResponse.error(response.message, error: response.error);
    }
  }

  @override
  Future<ApiResponse<List<WeightProgressEntity>>> getWeightProgress() async {
    final response = await chartDataSource.getWeightProgress();

    if (response.success && response.data != null) {
      final entities = response.data!.map((e) => e.toEntity()).toList();
      return ApiResponse.success(entities, message: response.message);
    } else {
      return ApiResponse.error(response.message, error: response.error);
    }
  }
}
