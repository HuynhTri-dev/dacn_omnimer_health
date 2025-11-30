import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_feedback_entity.dart';

class CreateWorkoutFeedbackUseCase {
  final WorkoutLogRepositoryAbs repository;

  CreateWorkoutFeedbackUseCase(this.repository);

  Future<ApiResponse<WorkoutFeedbackEntity>> call(
    WorkoutFeedbackEntity feedback,
  ) async {
    return await repository.createWorkoutFeedback(feedback);
  }
}
