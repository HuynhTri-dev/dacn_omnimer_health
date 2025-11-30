import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to get user's workout templates
class GetUserWorkoutTemplatesUseCase
    implements
        UseCase<ApiResponse<List<WorkoutTemplateEntity>>, NoParams> {
  final WorkoutTemplateRepositoryAbs repository;

  GetUserWorkoutTemplatesUseCase(this.repository);

  @override
  Future<ApiResponse<List<WorkoutTemplateEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getUserWorkoutTemplates();
  }
}

