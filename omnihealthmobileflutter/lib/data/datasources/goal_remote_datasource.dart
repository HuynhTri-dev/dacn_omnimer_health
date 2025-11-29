import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/goal/goal_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

abstract class GoalRemoteDataSource {
  Future<ApiResponse<List<GoalModel>>> getGoalsByUserId(String userId);
  Future<ApiResponse<GoalModel>> getGoalById(String id);
  Future<ApiResponse<GoalModel>> createGoal(GoalModel goal);
  Future<ApiResponse<GoalModel>> updateGoal(GoalModel goal);
  Future<ApiResponse<bool>> deleteGoal(String goalId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final ApiClient apiClient;

  GoalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<GoalModel>>> getGoalsByUserId(String userId) async {
    try {
      final response = await apiClient.get<List<GoalModel>>(
        Endpoints.getGoalsByUserId(userId),
        parser: (json) {
          if (json is List) {
            return json
                .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <GoalModel>[];
        },
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Lấy danh sách mục tiêu thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<GoalModel>> getGoalById(String id) async {
    try {
      final response = await apiClient.get<GoalModel>(
        Endpoints.getGoalById(id),
        parser: (json) => GoalModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Lấy chi tiết mục tiêu thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<GoalModel>> createGoal(GoalModel goal) async {
    try {
      final response = await apiClient.post<GoalModel>(
        Endpoints.createGoal,
        data: goal.toJson(),
        requiresAuth: true,
        parser: (json) => GoalModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error("Tạo mục tiêu thất bại: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<GoalModel>> updateGoal(GoalModel goal) async {
    try {
      final response = await apiClient.put<GoalModel>(
        Endpoints.updateGoal(goal.id!),
        data: goal.toJson(),
        parser: (json) => GoalModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error("Cập nhật mục tiêu thất bại: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<bool>> deleteGoal(String goalId) async {
    try {
      final response = await apiClient.delete<bool>(
        Endpoints.deleteGoal(goalId),
        parser: (json) => true,
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error("Xóa mục tiêu thất bại: ${e.toString()}");
    }
  }
}
