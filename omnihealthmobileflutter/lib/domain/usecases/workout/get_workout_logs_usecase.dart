import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// Use case to get user's workout logs history
class GetWorkoutLogsUseCase
    implements UseCase<ApiResponse<List<WorkoutLogEntity>>, NoParams> {
  final WorkoutLogRepositoryAbs repository;

  GetWorkoutLogsUseCase(this.repository);

  @override
  Future<ApiResponse<List<WorkoutLogEntity>>> call(NoParams params) async {
    return await repository.getUserWorkoutLogs();
  }
}

