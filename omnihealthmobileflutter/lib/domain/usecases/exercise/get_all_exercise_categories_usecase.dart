import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_category_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';
import '../base_usecase.dart';

class GetAllExerciseCategoriesUseCase
    implements UseCase<ApiResponse<List<ExerciseCategoryEntity>>, NoParams> {
  final ExerciseCategoryRepositoryAbs repository;

  GetAllExerciseCategoriesUseCase(this.repository);

  @override
  Future<ApiResponse<List<ExerciseCategoryEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getAllExerciseCategories();
  }
}
