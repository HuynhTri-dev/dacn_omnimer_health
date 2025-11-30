import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

/// UseCase to create workout template
class CreateWorkoutTemplateUseCase {
  final WorkoutTemplateRepositoryAbs repository;

  CreateWorkoutTemplateUseCase(this.repository);

  Future<ApiResponse<WorkoutTemplateEntity>> call(
    Map<String, dynamic> data,
  ) async {
    return await repository.createWorkoutTemplate(data);
  }
}

