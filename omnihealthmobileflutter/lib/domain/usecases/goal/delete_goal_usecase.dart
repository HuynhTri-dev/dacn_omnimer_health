import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';

class DeleteGoalUseCase {
  final GoalRepository _repository;

  DeleteGoalUseCase(this._repository);

  Future<void> call(String goalId) async {
    await _repository.deleteGoal(goalId);
  }
}