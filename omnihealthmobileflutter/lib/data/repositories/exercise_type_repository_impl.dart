import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_type_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_type_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';

/// Triển khai ExerciseTypeRepositoryAbs.
/// Chịu trách nhiệm chuyển đổi giữa Domain Entity và Data Model.
class ExerciseTypeRepositoryImpl implements ExerciseTypeRepositoryAbs {
  final ExerciseTypeDataSource exerciseTypeDataSource;

  ExerciseTypeRepositoryImpl({required this.exerciseTypeDataSource});

  @override
  Future<ApiResponse<List<ExerciseTypeEntity>>> getAllExerciseTypes() async {
    try {
      final response = await exerciseTypeDataSource.getAllExerciseTypes();

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <ExerciseTypeEntity>[];

      return ApiResponse<List<ExerciseTypeEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<ExerciseTypeEntity>>.error(
        "Không thể lấy danh sách exercise types: ${e.toString()}",
        error: e,
      );
    }
  }
}
