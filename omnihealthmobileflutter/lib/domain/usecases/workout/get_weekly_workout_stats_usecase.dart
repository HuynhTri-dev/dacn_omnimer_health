import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_stats_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_stats_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to get weekly workout statistics
class GetWeeklyWorkoutStatsUseCase
    implements UseCase<ApiResponse<WorkoutStatsEntity>, NoParams> {
  final WorkoutStatsRepositoryAbs repository;

  GetWeeklyWorkoutStatsUseCase(this.repository);

  @override
  Future<ApiResponse<WorkoutStatsEntity>> call(NoParams params) async {
    return await repository.getWeeklyWorkoutStats();
  }
}

