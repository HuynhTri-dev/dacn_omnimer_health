import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';

/// Abstract repository interface cho ExerciseType
/// Định nghĩa các method cần implement
abstract class ExerciseTypeRepositoryAbs {
  /// Lấy danh sách tất cả exercise types
  Future<ApiResponse<List<ExerciseTypeEntity>>> getAllExerciseTypes();
}
