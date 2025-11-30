import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';

enum ExerciseSelectionStatus {
  initial,
  loading,
  loaded,
  error,
}

class ExerciseSelectionState extends Equatable {
  final ExerciseSelectionStatus status;
  final List<ExerciseListEntity> exercises;
  final String searchQuery;
  final List<String> selectedEquipmentIds;
  final List<String> selectedMuscleIds;
  final String? selectedDifficulty;
  final String? errorMessage;

  const ExerciseSelectionState({
    this.status = ExerciseSelectionStatus.initial,
    this.exercises = const [],
    this.searchQuery = '',
    this.selectedEquipmentIds = const [],
    this.selectedMuscleIds = const [],
    this.selectedDifficulty,
    this.errorMessage,
  });

  ExerciseSelectionState copyWith({
    ExerciseSelectionStatus? status,
    List<ExerciseListEntity>? exercises,
    String? searchQuery,
    List<String>? selectedEquipmentIds,
    List<String>? selectedMuscleIds,
    String? selectedDifficulty,
    String? errorMessage,
  }) {
    return ExerciseSelectionState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedEquipmentIds: selectedEquipmentIds ?? this.selectedEquipmentIds,
      selectedMuscleIds: selectedMuscleIds ?? this.selectedMuscleIds,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<ExerciseListEntity> get filteredExercises {
    return exercises.where((exercise) {
      // Search filter
      if (searchQuery.isNotEmpty &&
          !exercise.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }

      // Difficulty filter
      if (selectedDifficulty != null &&
          selectedDifficulty!.isNotEmpty &&
          exercise.difficulty.toLowerCase() != selectedDifficulty!.toLowerCase()) {
        return false;
      }

      // Equipment filter
      if (selectedEquipmentIds.isNotEmpty) {
        final hasMatchingEquipment = exercise.equipments.any(
          (eq) => selectedEquipmentIds.contains(eq.id),
        );
        if (!hasMatchingEquipment) return false;
      }

      // Muscle filter
      if (selectedMuscleIds.isNotEmpty) {
        final hasMatchingMuscle = exercise.mainMuscles.any(
          (m) => selectedMuscleIds.contains(m.id),
        );
        if (!hasMatchingMuscle) return false;
      }

      return true;
    }).toList();
  }

  @override
  List<Object?> get props => [
        status,
        exercises,
        searchQuery,
        selectedEquipmentIds,
        selectedMuscleIds,
        selectedDifficulty,
        errorMessage,
      ];
}

