import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/workout_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_stats_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_stats_entity.dart';

/// Implementation of WorkoutStatsRepositoryAbs
class WorkoutStatsRepositoryImpl implements WorkoutStatsRepositoryAbs {
  final WorkoutDataSource workoutDataSource;

  WorkoutStatsRepositoryImpl({required this.workoutDataSource});

  @override
  Future<ApiResponse<WorkoutStatsEntity>> getWeeklyWorkoutStats() async {
    try {
      final response = await workoutDataSource.getWeeklyWorkoutStats();

      // Convert Model -> Entity
      final entity = response.data?.toEntity();

      return ApiResponse<WorkoutStatsEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<WorkoutStatsEntity>.error(
        "Không thể lấy thống kê workout: ${e.toString()}",
        error: e,
      );
    }
  }
}

