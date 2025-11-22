import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart'
    as bp;
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart'
    as eq;
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart'
    as ec;
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart'
    as et;
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';

enum ExerciseHomeStatus {
  initial,
  loadingFilters,
  filtersLoaded,
  loadingExercises,
  exercisesLoaded,
  loadingMore,
  error,
}

class ExerciseHomeState extends Equatable {
  final ExerciseHomeStatus status;
  final String? errorMessage;

  // Filter data
  final List<bp.BodyPartEntity> bodyParts;
  final List<eq.EquipmentEntity> equipments;
  final List<et.ExerciseTypeEntity> exerciseTypes;
  final List<ec.ExerciseCategoryEntity> categories;
  final List<MuscleEntity> muscles;

  // Exercise data
  final List<ExerciseListEntity> exercises;
  final bool hasMoreExercises;
  final int currentPage;

  // Selected muscle from 3D model
  final MuscleEntity? selectedMuscle;

  // Active filters
  final LocationEnum? activeLocation;
  final List<String> activeEquipmentIds;
  final List<String> activeMuscleIds;
  final List<String> activeExerciseTypeIds;
  final List<String> activeCategoryIds;
  final String? searchQuery;

  const ExerciseHomeState({
    this.status = ExerciseHomeStatus.initial,
    this.errorMessage,
    this.bodyParts = const [],
    this.equipments = const [],
    this.exerciseTypes = const [],
    this.categories = const [],
    this.muscles = const [],
    this.exercises = const [],
    this.hasMoreExercises = true,
    this.currentPage = 1,
    this.selectedMuscle,
    this.activeLocation,
    this.activeEquipmentIds = const [],
    this.activeMuscleIds = const [],
    this.activeExerciseTypeIds = const [],
    this.activeCategoryIds = const [],
    this.searchQuery,
  });

  ExerciseHomeState copyWith({
    ExerciseHomeStatus? status,
    String? errorMessage,
    List<bp.BodyPartEntity>? bodyParts,
    List<eq.EquipmentEntity>? equipments,
    List<et.ExerciseTypeEntity>? exerciseTypes,
    List<ec.ExerciseCategoryEntity>? categories,
    List<MuscleEntity>? muscles,
    List<ExerciseListEntity>? exercises,
    bool? hasMoreExercises,
    int? currentPage,
    MuscleEntity? selectedMuscle,
    LocationEnum? activeLocation,
    List<String>? activeEquipmentIds,
    List<String>? activeMuscleIds,
    List<String>? activeExerciseTypeIds,
    List<String>? activeCategoryIds,
    String? searchQuery,
    bool clearSelectedMuscle = false,
    bool clearErrorMessage = false,
  }) {
    return ExerciseHomeState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      bodyParts: bodyParts ?? this.bodyParts,
      equipments: equipments ?? this.equipments,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      categories: categories ?? this.categories,
      muscles: muscles ?? this.muscles,
      exercises: exercises ?? this.exercises,
      hasMoreExercises: hasMoreExercises ?? this.hasMoreExercises,
      currentPage: currentPage ?? this.currentPage,
      selectedMuscle: clearSelectedMuscle
          ? null
          : (selectedMuscle ?? this.selectedMuscle),
      activeLocation: activeLocation ?? this.activeLocation,
      activeEquipmentIds: activeEquipmentIds ?? this.activeEquipmentIds,
      activeMuscleIds: activeMuscleIds ?? this.activeMuscleIds,
      activeExerciseTypeIds:
          activeExerciseTypeIds ?? this.activeExerciseTypeIds,
      activeCategoryIds: activeCategoryIds ?? this.activeCategoryIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    bodyParts,
    equipments,
    exerciseTypes,
    categories,
    muscles,
    exercises,
    hasMoreExercises,
    currentPage,
    selectedMuscle,
    activeLocation,
    activeEquipmentIds,
    activeMuscleIds,
    activeExerciseTypeIds,
    activeCategoryIds,
    searchQuery,
  ];
}
