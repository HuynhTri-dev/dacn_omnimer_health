import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

/// UseCase to update workout template
class UpdateWorkoutTemplateUseCase {
  final WorkoutTemplateRepositoryAbs repository;

  UpdateWorkoutTemplateUseCase(this.repository);

  Future<ApiResponse<WorkoutTemplateEntity>> call(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await repository.updateWorkoutTemplate(id, data);
  }
}

