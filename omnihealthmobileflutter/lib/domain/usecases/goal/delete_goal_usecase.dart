import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class DeleteGoalUseCase implements UseCase<ApiResponse<bool>, String> {
  final GoalRepository _repository;

  DeleteGoalUseCase(this._repository);

  @override
  Future<ApiResponse<bool>> call(String params) async {
    return await _repository.deleteGoal(params);
  }
}
