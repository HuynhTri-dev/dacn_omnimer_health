import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

class FinishWorkoutUseCase {
  final WorkoutLogRepositoryAbs repository;

  FinishWorkoutUseCase(this.repository);

  Future<ApiResponse<WorkoutLogEntity>> call(
    String id,
    Map<String, dynamic> data,
  ) {
    return repository.finishWorkout(id, data);
  }
}
