import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository.dart';
import 'package:omnihealthmobileflutter/data/models/muscle/muscle_model.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository repo;

  ExerciseCubit(this.repo) : super(const ExerciseState());

  Future<void> loadData() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final exercises = await repo.getExercises();
      final muscles = await repo.getMuscles();

      emit(
        state.copyWith(
          loading: false,
          exercises: exercises,
          muscles: muscles,
          selectedMuscle: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> submitRating(ExerciseModel exercise, double score) async {
    try {
      // gọi API
      await repo.rateExercise(exerciseId: exercise.id, score: score);

      // cập nhật list exercises trong state để UI đổi ngay
      final updated = state.exercises.map((e) {
        if (e.id == exercise.id) {
          return e.copyWith(rating: score);
        }
        return e;
      }).toList();

      emit(state.copyWith(exercises: updated));
    } catch (e) {
      // tuỳ bạn muốn xử lý lỗi thế nào
      // ở đây mình chỉ log
      // debugPrint('submitRating error: $e');
    }
  }

  void selectMuscle(MuscleModel? muscle) {
    emit(state.copyWith(selectedMuscle: muscle));
  }

  void updateSearch(String value) {
    emit(state.copyWith(search: value));
  }

  void updateFilter(ExerciseFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
