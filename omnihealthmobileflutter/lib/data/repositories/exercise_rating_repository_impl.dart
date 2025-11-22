import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_rating_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_rating_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_rating_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_rating_entity.dart';

/// Triển khai ExerciseRatingRepositoryAbs.
/// Chịu trách nhiệm xử lý logic liên quan đến đánh giá bài tập.
class ExerciseRatingRepositoryImpl implements ExerciseRatingRepositoryAbs {
  final ExerciseRatingDataSource exerciseRatingDataSource;

  ExerciseRatingRepositoryImpl({required this.exerciseRatingDataSource});

  @override
  Future<ApiResponse<ExerciseRatingEntity>> rateExercise(
    ExerciseRatingEntity data,
  ) async {
    try {
      final dataModel = ExerciseRatingModel.fromEntity(data);

      final response = await exerciseRatingDataSource.rateExercise(dataModel);

      return ApiResponse<ExerciseRatingEntity>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<ExerciseRatingEntity>.error(
        "Không thể đánh giá bài tập: ${e.toString()}",
        error: e,
      );
    }
  }
}
