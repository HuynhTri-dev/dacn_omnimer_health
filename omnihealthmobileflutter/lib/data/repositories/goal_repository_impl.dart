import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/models/goal/goal_model.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/data/datasources/goal_remote_datasource.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;

  GoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<List<GoalEntity>>> getGoalsByUserId(String userId) async {
    try {
      final response = await remoteDataSource.getGoalsByUserId(userId);
      if (response.success && response.data != null) {
        final entities = response.data!
            .map((model) => model.toEntity())
            .toList();
        return ApiResponse.success(entities, message: response.message);
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<GoalEntity>> getGoalById(String id) async {
    try {
      final response = await remoteDataSource.getGoalById(id);
      if (response.success && response.data != null) {
        return ApiResponse.success(
          response.data!.toEntity(),
          message: response.message,
        );
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<GoalEntity>> createGoal(GoalEntity goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final response = await remoteDataSource.createGoal(model);
      if (response.success && response.data != null) {
        return ApiResponse.success(
          response.data!.toEntity(),
          message: response.message,
        );
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<GoalEntity>> updateGoal(GoalEntity goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final response = await remoteDataSource.updateGoal(model);
      if (response.success && response.data != null) {
        return ApiResponse.success(
          response.data!.toEntity(),
          message: response.message,
        );
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> deleteGoal(String goalId) async {
    try {
      final response = await remoteDataSource.deleteGoal(goalId);
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(e.toString());
    }
  }
}
