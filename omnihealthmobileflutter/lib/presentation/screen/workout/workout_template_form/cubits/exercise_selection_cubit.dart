import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercises_usecase.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';
import 'exercise_selection_state.dart';

class ExerciseSelectionCubit extends Cubit<ExerciseSelectionState> {
  final GetExercisesUseCase getExercisesUseCase;

  ExerciseSelectionCubit({
    required this.getExercisesUseCase,
  }) : super(const ExerciseSelectionState());

  /// Load exercises from API
  Future<void> loadExercises() async {
    emit(state.copyWith(status: ExerciseSelectionStatus.loading));

    try {
      final query = _buildQuery();
      final response = await getExercisesUseCase(query);

      if (response.success && response.data != null) {
        emit(
          state.copyWith(
            status: ExerciseSelectionStatus.loaded,
            exercises: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ExerciseSelectionStatus.error,
            errorMessage: response.message ?? 'Failed to load exercises',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseSelectionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Update equipment filter
  void updateEquipmentFilter(List<String> equipmentIds) {
    emit(state.copyWith(selectedEquipmentIds: equipmentIds));
  }

  /// Update muscle filter
  void updateMuscleFilter(List<String> muscleIds) {
    emit(state.copyWith(selectedMuscleIds: muscleIds));
  }

  /// Update difficulty filter
  void updateDifficultyFilter(String? difficulty) {
    emit(state.copyWith(selectedDifficulty: difficulty));
  }

  /// Clear all filters
  void clearFilters() {
    emit(
      state.copyWith(
        searchQuery: '',
        selectedEquipmentIds: const [],
        selectedMuscleIds: const [],
        selectedDifficulty: null,
      ),
    );
  }

  /// Build query for API
  DefaultQueryEntity _buildQuery() {
    final filters = <String, dynamic>{};

    // Add filters if needed
    if (state.selectedEquipmentIds.isNotEmpty) {
      filters['equipmentIds'] = state.selectedEquipmentIds;
    }

    if (state.selectedMuscleIds.isNotEmpty) {
      filters['muscleIds'] = state.selectedMuscleIds;
    }

    if (state.selectedDifficulty != null && state.selectedDifficulty!.isNotEmpty) {
      filters['difficulty'] = state.selectedDifficulty;
    }

    return DefaultQueryEntity(
      page: 1,
      limit: 100, // Load more exercises for selection
      filter: filters,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );
  }
}

