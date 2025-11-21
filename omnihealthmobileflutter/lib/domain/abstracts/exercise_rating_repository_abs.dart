import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_rating_entity.dart';

abstract class ExerciseRatingRepositoryAbs {
  /// Submit a rating for an exercise.
  /// Returns ApiResponse<ExerciseRatingEntity> containing the exercise rating or error.
  Future<ApiResponse<ExerciseRatingEntity>> rateExercise(
    ExerciseRatingEntity data,
  );
}
