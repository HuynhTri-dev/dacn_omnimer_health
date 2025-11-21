import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class GetGoalsUseCase {
  final HealthProfileRepository repository;

  GetGoalsUseCase(this.repository);

  Future<List<GoalEntity>> call() async {
    return await repository.getGoals();
  }
}

class AddGoalUseCase {
  final HealthProfileRepository repository;

  AddGoalUseCase(this.repository);

  Future<void> call(GoalEntity goal) async {
    return await repository.addGoal(goal);
  }
}