import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/workout_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_template_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// Implementation of WorkoutTemplateRepositoryAbs
class WorkoutTemplateRepositoryImpl implements WorkoutTemplateRepositoryAbs {
  final WorkoutDataSource workoutDataSource;

  WorkoutTemplateRepositoryImpl({required this.workoutDataSource});

  @override
  Future<ApiResponse<List<WorkoutTemplateEntity>>> getWorkoutTemplates(
    DefaultQueryEntity query,
  ) async {
    try {
      final response = await workoutDataSource.getWorkoutTemplates(query);

      logger.i("Response: ${response.data}");

      // Convert Model -> Entity
      final entities = response.data != null
          ? WorkoutTemplateModel.toEntityList(
              response.data!.map((model) => model.toJson()).toList(),
            )
          : <WorkoutTemplateEntity>[];

      logger.i("Entities: ${entities.length}");

      return ApiResponse<List<WorkoutTemplateEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<WorkoutTemplateEntity>>.error(
        "Không thể lấy danh sách workout template: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<List<WorkoutTemplateEntity>>>
      getUserWorkoutTemplates() async {
    try {
      final response = await workoutDataSource.getUserWorkoutTemplates();

      // Convert Model -> Entity
      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <WorkoutTemplateEntity>[];

      return ApiResponse<List<WorkoutTemplateEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<WorkoutTemplateEntity>>.error(
        "Không thể lấy workout templates của user: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> getWorkoutTemplateById(
    String id,
  ) async {
    try {
      final response = await workoutDataSource.getWorkoutTemplateById(id);

      // Convert Model -> Entity
      final entity = response.data?.toEntity();

      return ApiResponse<WorkoutTemplateEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<WorkoutTemplateEntity>.error(
        "Không thể lấy thông tin workout template: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> createWorkoutTemplate(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await workoutDataSource.createWorkoutTemplate(data);

      // Convert Model -> Entity
      final entity = response.data?.toEntity();

      return ApiResponse<WorkoutTemplateEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<WorkoutTemplateEntity>.error(
        "Không thể tạo workout template: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> updateWorkoutTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await workoutDataSource.updateWorkoutTemplate(id, data);

      // Convert Model -> Entity
      final entity = response.data?.toEntity();

      return ApiResponse<WorkoutTemplateEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<WorkoutTemplateEntity>.error(
        "Không thể cập nhật workout template: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<bool>> deleteWorkoutTemplate(String id) async {
    try {
      final response = await workoutDataSource.deleteWorkoutTemplate(id);

      return ApiResponse<bool>(
        success: response.success,
        message: response.message,
        data: response.data,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<bool>.error(
        "Không thể xóa workout template: ${e.toString()}",
        error: e,
      );
    }
  }
}

