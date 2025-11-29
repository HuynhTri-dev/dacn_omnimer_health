import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to get workout template by ID
class GetWorkoutTemplateByIdUseCase
    implements UseCase<ApiResponse<WorkoutTemplateEntity>, String> {
  final WorkoutTemplateRepositoryAbs repository;

  GetWorkoutTemplateByIdUseCase(this.repository);

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> call(String id) async {
    return await repository.getWorkoutTemplateById(id);
  }
}

