import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// UseCase to get all exercises from the repository
class GetExercisesUseCase
    implements
        UseCase<ApiResponse<List<ExerciseListEntity>>, DefaultQueryEntity> {
  final ExerciseRepositoryAbs repository;

  GetExercisesUseCase(this.repository);

  @override
  Future<ApiResponse<List<ExerciseListEntity>>> call(
    DefaultQueryEntity query,
  ) async {
    return await repository.getExercises(query);
  }
}
