import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

/// Abstract repository for Workout Log operations
abstract class WorkoutLogRepositoryAbs {
  /// Create new workout log
  Future<ApiResponse<WorkoutLogEntity>> createWorkoutLog(
    Map<String, dynamic> data,
  );

  /// Get user workout logs
  Future<ApiResponse<List<WorkoutLogEntity>>> getUserWorkoutLogs();

  /// Get workout log by ID
  Future<ApiResponse<WorkoutLogEntity>> getWorkoutLogById(String id);

  /// Delete workout log
  Future<ApiResponse<bool>> deleteWorkoutLog(String id);
}
