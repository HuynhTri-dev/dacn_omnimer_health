import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/workout_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Implementation of WorkoutLogRepositoryAbs
class WorkoutLogRepositoryImpl implements WorkoutLogRepositoryAbs {
  final WorkoutDataSource workoutDataSource;

  WorkoutLogRepositoryImpl({required this.workoutDataSource});

  @override
  Future<ApiResponse<WorkoutLogEntity>> createWorkoutLog(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await workoutDataSource.createWorkoutLog(data);

      final entity = response.data?.toEntity();

      return ApiResponse<WorkoutLogEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      logger.e('[WorkoutLogRepository] createWorkoutLog error: $e');
      return ApiResponse<WorkoutLogEntity>.error(
        "Không thể lưu workout log: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<List<WorkoutLogEntity>>> getUserWorkoutLogs() async {
    try {
      final response = await workoutDataSource.getUserWorkoutLogs();

      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <WorkoutLogEntity>[];

      return ApiResponse<List<WorkoutLogEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      logger.e('[WorkoutLogRepository] getUserWorkoutLogs error: $e');
      return ApiResponse<List<WorkoutLogEntity>>.error(
        "Không thể lấy danh sách workout logs: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<WorkoutLogEntity>> getWorkoutLogById(String id) async {
    try {
      final response = await workoutDataSource.getWorkoutLogById(id);

      final entity = response.data?.toEntity();

      return ApiResponse<WorkoutLogEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      logger.e('[WorkoutLogRepository] getWorkoutLogById error: $e');
      return ApiResponse<WorkoutLogEntity>.error(
        "Không thể lấy workout log: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<bool>> deleteWorkoutLog(String id) async {
    try {
      final response = await workoutDataSource.deleteWorkoutLog(id);

      return ApiResponse<bool>(
        success: response.success,
        message: response.message,
        data: response.data,
        error: response.error,
      );
    } catch (e) {
      logger.e('[WorkoutLogRepository] deleteWorkoutLog error: $e');
      return ApiResponse<bool>.error(
        "Không thể xóa workout log: ${e.toString()}",
        error: e,
      );
    }
  }
}
