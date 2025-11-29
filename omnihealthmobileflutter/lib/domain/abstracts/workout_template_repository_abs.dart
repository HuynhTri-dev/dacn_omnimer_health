import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// Abstract repository for Workout Template operations
abstract class WorkoutTemplateRepositoryAbs {
  /// Get all workout templates
  Future<ApiResponse<List<WorkoutTemplateEntity>>> getWorkoutTemplates(
    DefaultQueryEntity query,
  );

  /// Get workout templates for current user
  Future<ApiResponse<List<WorkoutTemplateEntity>>> getUserWorkoutTemplates();

  /// Get workout template by ID
  Future<ApiResponse<WorkoutTemplateEntity>> getWorkoutTemplateById(String id);

  /// Create new workout template
  Future<ApiResponse<WorkoutTemplateEntity>> createWorkoutTemplate(
    Map<String, dynamic> data,
  );

  /// Update workout template
  Future<ApiResponse<WorkoutTemplateEntity>> updateWorkoutTemplate(
    String id,
    Map<String, dynamic> data,
  );

  /// Delete workout template
  Future<ApiResponse<bool>> deleteWorkoutTemplate(String id);
}

