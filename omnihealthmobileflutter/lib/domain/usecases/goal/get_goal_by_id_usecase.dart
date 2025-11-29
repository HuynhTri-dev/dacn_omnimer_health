import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class GetGoalByIdUseCase {
  final GoalRepository repository;

  GetGoalByIdUseCase(this.repository);

  Future<ApiResponse<GoalEntity>> call(String id) {
    return repository.getGoalById(id);
  }
}
