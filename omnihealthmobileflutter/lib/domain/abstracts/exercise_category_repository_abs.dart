import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';

/// Abstract repository interface cho ExerciseCategory
/// Định nghĩa các method cần implement
abstract class ExerciseCategoryRepositoryAbs {
  /// Lấy danh sách tất cả exercise categories
  Future<ApiResponse<List<ExerciseCategoryEntity>>> getAllExerciseCategories();
}
