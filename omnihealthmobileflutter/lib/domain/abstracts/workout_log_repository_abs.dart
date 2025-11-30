import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_feedback_entity.dart';

/// Abstract repository for Workout Log operations
abstract class WorkoutLogRepositoryAbs {
  /// Create new workout log
  Future<ApiResponse<WorkoutLogEntity>> createWorkoutLog(
    Map<String, dynamic> data,
  );

  /// Create workout from template
  Future<ApiResponse<WorkoutLogEntity>> createWorkoutFromTemplate(
    String templateId,
  );

  /// Get user workout logs
  Future<ApiResponse<List<WorkoutLogEntity>>> getUserWorkoutLogs();

  /// Get workout log by ID
  Future<ApiResponse<WorkoutLogEntity>> getWorkoutLogById(String id);

  /// Delete workout log
  Future<ApiResponse<bool>> deleteWorkoutLog(String id);

  /// Complete a set in a workout
  Future<ApiResponse<WorkoutLogEntity>> completeSet(
    String id,
    Map<String, dynamic> data,
  );

  /// Complete an exercise in a workout
  Future<ApiResponse<WorkoutLogEntity>> completeExercise(
    String id,
    Map<String, dynamic> data,
  );

  /// Finish a workout
  Future<ApiResponse<WorkoutLogEntity>> finishWorkout(
    String id,
    Map<String, dynamic> data,
  );

  /// Start a workout
  Future<ApiResponse<WorkoutLogEntity>> startWorkout(String id);

  /// Create workout feedback
  Future<ApiResponse<WorkoutFeedbackEntity>> createWorkoutFeedback(
    WorkoutFeedbackEntity feedback,
  );
}
