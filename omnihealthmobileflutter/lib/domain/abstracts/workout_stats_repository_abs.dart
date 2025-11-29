import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_stats_entity.dart';

/// Abstract repository for Workout Stats operations
abstract class WorkoutStatsRepositoryAbs {
  /// Get weekly workout statistics for current user
  Future<ApiResponse<WorkoutStatsEntity>> getWeeklyWorkoutStats();
}

