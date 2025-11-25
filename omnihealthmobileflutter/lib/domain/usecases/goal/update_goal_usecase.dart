import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class UpdateGoalUseCase {
  final GoalRepository _repository;

  UpdateGoalUseCase(this._repository);

  Future<GoalEntity> call(GoalEntity goal) async {
    return await _repository.updateGoal(goal);
  }
}