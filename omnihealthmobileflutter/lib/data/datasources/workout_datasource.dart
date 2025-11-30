import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_template_model.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_stats_model.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_log_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_feedback_model.dart';

/// DataSource for Workout Template API calls
class WorkoutDataSource {
  final ApiClient apiClient;

  WorkoutDataSource({required this.apiClient});

  /// Get all workout templates with query params
  Future<ApiResponse<List<WorkoutTemplateModel>>> getWorkoutTemplates(
    DefaultQueryEntity query,
  ) async {
    try {
      final queryParams = query.toQueryBuilder().build();
      final response = await apiClient.get<List<WorkoutTemplateModel>>(
        Endpoints.getWorkoutTemplates,
        query: queryParams,
        parser: (data) {
          if (data is List) {
            return data
                .map(
                  (json) => WorkoutTemplateModel.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          return <WorkoutTemplateModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<WorkoutTemplateModel>>.error(
        "Failed to get workout templates: ${e.toString()}",
      );
    }
  }

  /// Get workout templates for current user
  Future<ApiResponse<List<WorkoutTemplateModel>>>
  getUserWorkoutTemplates() async {
    try {
      // Add query params to get all templates (high limit)
      final queryParams = {'limit': '100', 'page': '1'};

      logger.i(
        '[getUserWorkoutTemplates] Calling API with query: $queryParams',
      );

      final response = await apiClient.get<List<WorkoutTemplateModel>>(
        Endpoints.getUserWorkoutTemplates,
        query: queryParams,
        parser: (data) {
          logger.i(
            '[getUserWorkoutTemplates] Raw data type: ${data.runtimeType}',
          );
          logger.i('[getUserWorkoutTemplates] Raw data: $data');

          if (data is List) {
            logger.i(
              '[getUserWorkoutTemplates] Parsed ${data.length} templates from server',
            );
            return data
                .map(
                  (json) => WorkoutTemplateModel.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          logger.w(
            '[getUserWorkoutTemplates] Data is not a List, returning empty',
          );
          return <WorkoutTemplateModel>[];
        },
      );

      logger.i(
        '[getUserWorkoutTemplates] Response success: ${response.success}, data count: ${response.data?.length ?? 0}',
      );

      return response;
    } catch (e) {
      logger.e('[getUserWorkoutTemplates] Error: $e');
      return ApiResponse<List<WorkoutTemplateModel>>.error(
        "Failed to get user workout templates: ${e.toString()}",
      );
    }
  }

  /// Get workout template by ID
  Future<ApiResponse<WorkoutTemplateModel>> getWorkoutTemplateById(
    String id,
  ) async {
    try {
      final response = await apiClient.get<WorkoutTemplateModel>(
        Endpoints.getWorkoutTemplateById(id),
        parser: (data) =>
            WorkoutTemplateModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<WorkoutTemplateModel>.error(
        "Failed to get workout template: ${e.toString()}",
      );
    }
  }

  /// Create new workout template
  Future<ApiResponse<WorkoutTemplateModel>> createWorkoutTemplate(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.post<WorkoutTemplateModel>(
        Endpoints.createWorkoutTemplate,
        data: data,
        parser: (data) =>
            WorkoutTemplateModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<WorkoutTemplateModel>.error(
        "Failed to create workout template: ${e.toString()}",
      );
    }
  }

  /// Update workout template
  Future<ApiResponse<WorkoutTemplateModel>> updateWorkoutTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.put<WorkoutTemplateModel>(
        Endpoints.updateWorkoutTemplate(id),
        data: data,
        parser: (data) =>
            WorkoutTemplateModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<WorkoutTemplateModel>.error(
        "Failed to update workout template: ${e.toString()}",
      );
    }
  }

  /// Delete workout template
  Future<ApiResponse<bool>> deleteWorkoutTemplate(String id) async {
    try {
      final response = await apiClient.delete<bool>(
        Endpoints.deleteWorkoutTemplate(id),
        parser: (data) => true,
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<bool>.error(
        "Failed to delete workout template: ${e.toString()}",
      );
    }
  }

  /// Get weekly workout stats (mock data for now)
  /// TODO: Implement actual API endpoint when backend is ready
  Future<ApiResponse<WorkoutStatsModel>> getWeeklyWorkoutStats() async {
    try {
      // Mock data matching the chart in the image
      await Future.delayed(const Duration(milliseconds: 500));

      final mockStats = WorkoutStatsModel(
        weeklyStats: [
          WeeklyWorkoutStatsModel(dayOfWeek: 'Mon', hours: 2, workoutCount: 1),
          WeeklyWorkoutStatsModel(dayOfWeek: 'Tue', hours: 2, workoutCount: 2),
          WeeklyWorkoutStatsModel(dayOfWeek: 'Wed', hours: 2, workoutCount: 1),
          WeeklyWorkoutStatsModel(dayOfWeek: 'Thu', hours: 2, workoutCount: 2),
          WeeklyWorkoutStatsModel(dayOfWeek: 'Fri', hours: 2, workoutCount: 1),
          WeeklyWorkoutStatsModel(dayOfWeek: 'Sat', hours: 2, workoutCount: 1),
          WeeklyWorkoutStatsModel(dayOfWeek: 'Sun', hours: 2, workoutCount: 1),
        ],
        totalHoursThisWeek: 14,
        totalWorkoutsThisWeek: 9,
      );

      return ApiResponse<WorkoutStatsModel>.success(
        mockStats,
        message: 'Weekly stats retrieved successfully',
      );
    } catch (e) {
      logger.e('Exception in getWeeklyWorkoutStats: $e');
      return ApiResponse<WorkoutStatsModel>.error(
        'Failed to get weekly stats: $e',
        error: e,
      );
    }
  }

  // ================== WORKOUT LOG METHODS ==================

  /// Create a new workout log
  Future<ApiResponse<WorkoutLogModel>> createWorkoutLog(
    Map<String, dynamic> data,
  ) async {
    try {
      logger.i('[createWorkoutLog] Creating workout log with data: $data');

      final response = await apiClient.post<WorkoutLogModel>(
        Endpoints.createWorkout,
        data: data,
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );

      logger.i('[createWorkoutLog] Response: ${response.success}');
      return response;
    } catch (e) {
      logger.e('[createWorkoutLog] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to create workout log: ${e.toString()}",
      );
    }
  }

  /// Create workout from template
  Future<ApiResponse<WorkoutLogModel>> createWorkoutFromTemplate(
    String templateId,
  ) async {
    try {
      final response = await apiClient.post<WorkoutLogModel>(
        Endpoints.createWorkoutFromTemplate(templateId),
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e('[createWorkoutFromTemplate] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to create workout from template: ${e.toString()}",
      );
    }
  }

  /// Get user workout logs
  Future<ApiResponse<List<WorkoutLogModel>>> getUserWorkoutLogs() async {
    try {
      final queryParams = {'limit': '100', 'page': '1'};

      final response = await apiClient.get<List<WorkoutLogModel>>(
        Endpoints.getUserWorkouts,
        query: queryParams,
        parser: (data) {
          if (data is List) {
            return data
                .map(
                  (json) =>
                      WorkoutLogModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
          }
          return <WorkoutLogModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e('[getUserWorkoutLogs] Error: $e');
      return ApiResponse<List<WorkoutLogModel>>.error(
        "Failed to get user workout logs: ${e.toString()}",
      );
    }
  }

  /// Get workout log by ID
  Future<ApiResponse<WorkoutLogModel>> getWorkoutLogById(String id) async {
    try {
      final response = await apiClient.get<WorkoutLogModel>(
        Endpoints.getWorkoutById(id),
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e('[getWorkoutLogById] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to get workout log: ${e.toString()}",
      );
    }
  }

  /// Delete workout log
  Future<ApiResponse<bool>> deleteWorkoutLog(String id) async {
    try {
      final response = await apiClient.delete<bool>(
        Endpoints.deleteWorkout(id),
        parser: (data) => true,
      );

      return response;
    } catch (e) {
      logger.e('[deleteWorkoutLog] Error: $e');
      return ApiResponse<bool>.error(
        "Failed to delete workout log: ${e.toString()}",
      );
    }
  }

  /// Complete a set in a workout
  Future<ApiResponse<WorkoutLogModel>> completeSet(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.patch<WorkoutLogModel>(
        Endpoints.completeWorkoutSet(id),
        data: data,
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e('[completeSet] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to complete set: ${e.toString()}",
      );
    }
  }

  /// Complete an exercise in a workout
  Future<ApiResponse<WorkoutLogModel>> completeExercise(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.patch<WorkoutLogModel>(
        Endpoints.completeWorkoutExercise(id),
        data: data,
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e('[completeExercise] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to complete exercise: ${e.toString()}",
      );
    }
  }

  /// Finish a workout
  Future<ApiResponse<WorkoutLogModel>> finishWorkout(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.patch<WorkoutLogModel>(
        Endpoints.finishWorkout(id),
        data: data,
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e('[finishWorkout] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to finish workout: ${e.toString()}",
      );
    }
  }

  /// Start a workout
  Future<ApiResponse<WorkoutLogModel>> startWorkout(String id) async {
    try {
      final response = await apiClient.patch<WorkoutLogModel>(
        Endpoints.startWorkout(id),
        parser: (data) =>
            WorkoutLogModel.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e('[startWorkout] Error: $e');
      return ApiResponse<WorkoutLogModel>.error(
        "Failed to start workout: ${e.toString()}",
      );
    }
  }

  /// Create workout feedback
  Future<ApiResponse<WorkoutFeedbackModel>> createWorkoutFeedback(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.post<WorkoutFeedbackModel>(
        Endpoints.createWorkoutFeedback,
        data: data,
        parser: (data) =>
            WorkoutFeedbackModel.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e('[createWorkoutFeedback] Error: $e');
      return ApiResponse<WorkoutFeedbackModel>.error(
        "Failed to create workout feedback: ${e.toString()}",
      );
    }
  }
}
