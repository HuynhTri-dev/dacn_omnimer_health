import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'exercise_detail_state.dart';

class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  final ExerciseRepository repo;

  ExerciseDetailCubit(this.repo) : super(const ExerciseDetailState());

  Future<bool> submitRating(ExerciseModel exercise, double score) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repo.rateExercise(exerciseId: exercise.id, score: score);

      emit(state.copyWith(loading: false, currentRating: score));
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        emit(state.copyWith(loading: false));
        return false;
      }

      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }
}
