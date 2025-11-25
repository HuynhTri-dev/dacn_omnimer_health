import 'package:omnihealthmobileflutter/data/models/health_profile/goal/goal_model.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/data/datasources/goal_remote_datasource.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;

  GoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GoalEntity>> getGoalsByUserId(String userId) async {
    final models = await remoteDataSource.getGoalsByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<GoalEntity> createGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    final createdModel = await remoteDataSource.createGoal(model);
    return createdModel.toEntity();
  }

  @override
  Future<GoalEntity> updateGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    final updatedModel = await remoteDataSource.updateGoal(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await remoteDataSource.deleteGoal(goalId);
  }
}