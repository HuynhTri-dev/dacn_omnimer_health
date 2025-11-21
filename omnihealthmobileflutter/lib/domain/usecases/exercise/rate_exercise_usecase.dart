import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_rating_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_rating_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to submit a rating for an exercise
class RateExerciseUseCase
    implements UseCase<ApiResponse<void>, ExerciseRatingEntity> {
  final ExerciseRatingRepositoryAbs repository;

  RateExerciseUseCase(this.repository);

  @override
  Future<ApiResponse<void>> call(ExerciseRatingEntity data) async {
    return await repository.rateExercise(data);
  }
}
