import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to delete workout template
class DeleteWorkoutTemplateUseCase
    implements UseCase<ApiResponse<bool>, String> {
  final WorkoutTemplateRepositoryAbs repository;

  DeleteWorkoutTemplateUseCase(this.repository);

  @override
  Future<ApiResponse<bool>> call(String id) async {
    return await repository.deleteWorkoutTemplate(id);
  }
}

