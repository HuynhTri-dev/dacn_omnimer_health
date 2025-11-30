import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// UseCase to get all workout templates
class GetWorkoutTemplatesUseCase
    implements
        UseCase<ApiResponse<List<WorkoutTemplateEntity>>, DefaultQueryEntity> {
  final WorkoutTemplateRepositoryAbs repository;

  GetWorkoutTemplatesUseCase(this.repository);

  @override
  Future<ApiResponse<List<WorkoutTemplateEntity>>> call(
    DefaultQueryEntity query,
  ) async {
    return await repository.getWorkoutTemplates(query);
  }
}

