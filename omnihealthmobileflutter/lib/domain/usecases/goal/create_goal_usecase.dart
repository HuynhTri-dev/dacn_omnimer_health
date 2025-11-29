import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class CreateGoalUseCase
    implements UseCase<ApiResponse<GoalEntity>, GoalEntity> {
  final GoalRepository _repository;

  CreateGoalUseCase(this._repository);

  @override
  Future<ApiResponse<GoalEntity>> call(GoalEntity params) async {
    return await _repository.createGoal(params);
  }
}
