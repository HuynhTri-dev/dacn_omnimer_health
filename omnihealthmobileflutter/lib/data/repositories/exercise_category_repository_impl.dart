import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_category_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_category_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';

/// Triển khai ExerciseCategoryRepositoryAbs.
/// Chịu trách nhiệm chuyển đổi giữa Domain Entity và Data Model.
class ExerciseCategoryRepositoryImpl implements ExerciseCategoryRepositoryAbs {
  final ExerciseCategoryDataSource exerciseCategoryDataSource;

  ExerciseCategoryRepositoryImpl({required this.exerciseCategoryDataSource});

  @override
  Future<ApiResponse<List<ExerciseCategoryEntity>>>
  getAllExerciseCategories() async {
    try {
      final response = await exerciseCategoryDataSource
          .getAllExerciseCategories();

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <ExerciseCategoryEntity>[];

      return ApiResponse<List<ExerciseCategoryEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<ExerciseCategoryEntity>>.error(
        "Không thể lấy danh sách exercise categories: ${e.toString()}",
        error: e,
      );
    }
  }
}
