import 'package:equatable/equatable.dart';

abstract class ExerciseHomeEvent extends Equatable {
  const ExerciseHomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialData extends ExerciseHomeEvent {}

class LoadExercises extends ExerciseHomeEvent {}

class LoadMoreExercises extends ExerciseHomeEvent {}

class SearchExercises extends ExerciseHomeEvent {
  final String query;

  const SearchExercises(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyFilters extends ExerciseHomeEvent {
  final String? location;
  final List<String>? equipmentIds;
  final List<String>? muscleIds;
  final List<String>? exerciseTypeIds;
  final List<String>? categoryIds;

  const ApplyFilters({
    this.location,
    this.equipmentIds,
    this.muscleIds,
    this.exerciseTypeIds,
    this.categoryIds,
  });

  @override
  List<Object?> get props => [
    location,
    equipmentIds,
    muscleIds,
    exerciseTypeIds,
    categoryIds,
  ];
}

class ClearFilters extends ExerciseHomeEvent {}

class SelectMuscleById extends ExerciseHomeEvent {
  final String muscleId;

  const SelectMuscleById(this.muscleId);

  @override
  List<Object?> get props => [muscleId];
}
