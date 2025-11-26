import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

abstract class GoalRepository {
  Future<ApiResponse<List<GoalEntity>>> getGoalsByUserId(String userId);
  Future<ApiResponse<GoalEntity>> getGoalById(String id);
  Future<ApiResponse<GoalEntity>> createGoal(GoalEntity goal);
  Future<ApiResponse<GoalEntity>> updateGoal(GoalEntity goal);
  Future<ApiResponse<bool>> deleteGoal(String goalId);
}
