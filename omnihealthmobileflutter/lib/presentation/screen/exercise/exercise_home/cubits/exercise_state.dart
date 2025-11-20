import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'package:omnihealthmobileflutter/data/models/muscle/muscle_model.dart';

class ExerciseFilter {
  final Set<String> equipmentIds;
  final Set<String> muscleIds;
  final Set<String> exerciseTypes;
  final Set<String> exerciseCategories;
  final Set<String> locations;

  const ExerciseFilter({
    this.equipmentIds = const <String>{},
    this.muscleIds = const <String>{},
    this.exerciseTypes = const <String>{},
    this.exerciseCategories = const <String>{},
    this.locations = const <String>{},
  });

  bool get isEmpty =>
      equipmentIds.isEmpty &&
      muscleIds.isEmpty &&
      exerciseTypes.isEmpty &&
      exerciseCategories.isEmpty &&
      locations.isEmpty;

  ExerciseFilter copyWith({
    Set<String>? equipmentIds,
    Set<String>? muscleIds,
    Set<String>? exerciseTypes,
    Set<String>? exerciseCategories,
    Set<String>? locations,
  }) {
    return ExerciseFilter(
      equipmentIds: equipmentIds ?? this.equipmentIds,
      muscleIds: muscleIds ?? this.muscleIds,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      locations: locations ?? this.locations,
    );
  }
}

class ExerciseState extends Equatable {
  final bool loading;
  final List<ExerciseModel> exercises;
  final List<MuscleModel> muscles;
  final MuscleModel? selectedMuscle;
  final String? error;

  final String search;
  final ExerciseFilter filter;

  const ExerciseState({
    this.loading = false,
    this.exercises = const [],
    this.muscles = const [],
    this.selectedMuscle,
    this.error,
    this.search = '',
    this.filter = const ExerciseFilter(),
  });

  ExerciseState copyWith({
    bool? loading,
    List<ExerciseModel>? exercises,
    List<MuscleModel>? muscles,
    MuscleModel? selectedMuscle,
    String? error,
    String? search,
    ExerciseFilter? filter,
  }) {
    return ExerciseState(
      loading: loading ?? this.loading,
      exercises: exercises ?? this.exercises,
      muscles: muscles ?? this.muscles,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      error: error,
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    exercises,
    muscles,
    selectedMuscle,
    error,
    search,
    filter,
  ];
}
