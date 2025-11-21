import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_rating_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến Exercise Rating
abstract class ExerciseRatingDataSource {
  /// Submit a rating for an exercise
  Future<ApiResponse<ExerciseRatingModel>> rateExercise(
    ExerciseRatingModel data,
  );
}

class ExerciseRatingDataSourceImpl implements ExerciseRatingDataSource {
  final ApiClient apiClient;

  ExerciseRatingDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<ExerciseRatingModel>> rateExercise(
    ExerciseRatingModel data,
  ) async {
    try {
      final response = await apiClient.post<ExerciseRatingModel>(
        Endpoints.createExerciseRating,
        data: data.toJson(),
        parser: (json) => ExerciseRatingModel.fromJson(json),
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<ExerciseRatingModel>.error(
        "Đánh giá bài tập thất bại: ${e.toString()}",
      );
    }
  }
}
