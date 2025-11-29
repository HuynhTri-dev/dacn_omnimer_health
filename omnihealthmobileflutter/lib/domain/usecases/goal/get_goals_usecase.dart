import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetGoalsUseCase
    implements UseCase<ApiResponse<List<GoalEntity>>, String> {
  final GoalRepository _repository;

  GetGoalsUseCase(this._repository);

  @override
  Future<ApiResponse<List<GoalEntity>>> call(String params) async {
    return await _repository.getGoalsByUserId(params);
  }
}
