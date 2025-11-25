import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> getGoalsByUserId(String userId);
  Future<GoalEntity> createGoal(GoalEntity goal);
  Future<GoalEntity> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String goalId);
}