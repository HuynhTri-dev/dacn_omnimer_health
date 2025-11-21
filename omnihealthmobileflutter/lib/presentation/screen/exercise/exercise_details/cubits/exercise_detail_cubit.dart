import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_rating_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercise_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/rate_exercise_usecase.dart';
import 'exercise_detail_state.dart';

class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  final GetExerciseByIdUseCase getExerciseByIdUseCase;
  final RateExerciseUseCase rateExerciseUseCase;

  ExerciseDetailCubit({
    required this.getExerciseByIdUseCase,
    required this.rateExerciseUseCase,
  }) : super(const ExerciseDetailState());

  /// Load exercise details by ID
  Future<void> loadExerciseDetail(String exerciseId) async {
    emit(
      state.copyWith(status: ExerciseDetailStatus.loading, errorMessage: null),
    );

    try {
      final response = await getExerciseByIdUseCase(exerciseId);

      if (response.success && response.data != null) {
        emit(
          state.copyWith(
            status: ExerciseDetailStatus.loaded,
            exercise: response.data,
            userRating: response.data!.averageScore,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ExerciseDetailStatus.error,
            errorMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to load exercise details',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Submit rating for exercise
  Future<bool> submitRating({
    required String exerciseId,
    required double score,
  }) async {
    emit(
      state.copyWith(status: ExerciseDetailStatus.rating, errorMessage: null),
    );

    try {
      final ratingEntity = ExerciseRatingEntity(
        exerciseId: exerciseId,
        userId: '', // Backend will extract from token
        score: score,
      );

      final response = await rateExerciseUseCase(ratingEntity);

      if (response.success) {
        emit(
          state.copyWith(status: ExerciseDetailStatus.rated, userRating: score),
        );
        return true;
      } else {
        emit(
          state.copyWith(
            status: ExerciseDetailStatus.error,
            errorMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to submit rating',
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Reset to loaded state after rating
  void resetToLoaded() {
    if (state.status == ExerciseDetailStatus.rated) {
      emit(state.copyWith(status: ExerciseDetailStatus.loaded));
    }
  }
}
