import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/chart_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetGoalProgressUseCase
    implements UseCase<ApiResponse<List<GoalProgressEntity>>, NoParams> {
  final ChartRepositoryAbs repository;

  GetGoalProgressUseCase(this.repository);

  @override
  Future<ApiResponse<List<GoalProgressEntity>>> call(NoParams params) {
    return repository.getGoalProgress();
  }
}
