import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

class CompleteWorkoutExerciseUseCase {
  final WorkoutLogRepositoryAbs repository;

  CompleteWorkoutExerciseUseCase(this.repository);

  Future<ApiResponse<WorkoutLogEntity>> call(
    String id,
    Map<String, dynamic> data,
  ) {
    return repository.completeExercise(id, data);
  }
}
