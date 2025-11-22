import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile_entity.dart';

abstract class HealthProfileRepository {
  Future<HealthProfileEntity> getHealthProfile();
  Future<void> updateHealthProfile(HealthProfileEntity profile);
  Future<void> deleteHealthProfile();
  Future<List<GoalEntity>> getGoals();
  Future<void> addGoal(GoalEntity goal);
  Future<void> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String goalId);
}