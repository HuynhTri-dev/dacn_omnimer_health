import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_list_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_detail_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// Triển khai ExerciseRepositoryAbs.
/// Chịu trách nhiệm chuyển đổi giữa Domain Entity và Data Model.
class ExerciseRepositoryImpl implements ExerciseRepositoryAbs {
  final ExerciseDataSource exerciseDataSource;

  ExerciseRepositoryImpl({required this.exerciseDataSource});

  @override
  Future<ApiResponse<List<ExerciseListEntity>>> getExercises(
    DefaultQueryEntity query,
  ) async {
    try {
      final response = await exerciseDataSource.getExercises(query);

      logger.i("Response: ${response.data}");

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? ExerciseListModel.toEntityList(response.data!)
          : <ExerciseListEntity>[];

      logger.i("Entities: ${entities}");

      return ApiResponse<List<ExerciseListEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<ExerciseListEntity>>.error(
        "Không thể lấy danh sách bài tập: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<ExerciseDetailEntity>> getExerciseById(String id) async {
    try {
      final response = await exerciseDataSource.getExerciseById(id);

      // Chuyển Model -> Entity
      final entity = response.data?.toEntity();

      return ApiResponse<ExerciseDetailEntity>(
        success: response.success,
        message: response.message,
        data: entity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<ExerciseDetailEntity>.error(
        "Không thể lấy thông tin bài tập: ${e.toString()}",
        error: e,
      );
    }
  }
}
