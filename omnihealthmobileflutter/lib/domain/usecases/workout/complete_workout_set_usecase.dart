import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

class CompleteWorkoutSetUseCase {
  final WorkoutLogRepositoryAbs repository;

  CompleteWorkoutSetUseCase(this.repository);

  Future<ApiResponse<WorkoutLogEntity>> call(
    String id,
    Map<String, dynamic> data,
  ) {
    return repository.completeSet(id, data);
  }
}
