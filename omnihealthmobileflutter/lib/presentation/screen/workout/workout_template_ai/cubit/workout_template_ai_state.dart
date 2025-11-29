import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

enum WorkoutTemplateAIStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class WorkoutTemplateAIState extends Equatable {
  final WorkoutTemplateAIStatus status;
  final List<BodyPartEntity> bodyParts;
  final List<EquipmentEntity> equipments;
  final List<ExerciseCategoryEntity> exerciseCategories;
  final List<ExerciseTypeEntity> exerciseTypes;
  final List<MuscleEntity> muscles;

  final List<String> selectedBodyPartIds;
  final List<String> selectedEquipmentIds;
  final List<String> selectedExerciseCategoryIds;
  final List<String> selectedExerciseTypeIds;
  final List<String> selectedMuscleIds;
  final LocationEnum selectedLocation;

  final WorkoutTemplateEntity? recommendedWorkout;
  final String? errorMessage;

  const WorkoutTemplateAIState({
    this.status = WorkoutTemplateAIStatus.initial,
    this.bodyParts = const [],
    this.equipments = const [],
    this.exerciseCategories = const [],
    this.exerciseTypes = const [],
    this.muscles = const [],
    this.selectedBodyPartIds = const [],
    this.selectedEquipmentIds = const [],
    this.selectedExerciseCategoryIds = const [],
    this.selectedExerciseTypeIds = const [],
    this.selectedMuscleIds = const [],
    this.selectedLocation = LocationEnum.None,
    this.recommendedWorkout,
    this.errorMessage,
  });

  WorkoutTemplateAIState copyWith({
    WorkoutTemplateAIStatus? status,
    List<BodyPartEntity>? bodyParts,
    List<EquipmentEntity>? equipments,
    List<ExerciseCategoryEntity>? exerciseCategories,
    List<ExerciseTypeEntity>? exerciseTypes,
    List<MuscleEntity>? muscles,
    List<String>? selectedBodyPartIds,
    List<String>? selectedEquipmentIds,
    List<String>? selectedExerciseCategoryIds,
    List<String>? selectedExerciseTypeIds,
    List<String>? selectedMuscleIds,
    LocationEnum? selectedLocation,
    WorkoutTemplateEntity? recommendedWorkout,
    String? errorMessage,
  }) {
    return WorkoutTemplateAIState(
      status: status ?? this.status,
      bodyParts: bodyParts ?? this.bodyParts,
      equipments: equipments ?? this.equipments,
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      muscles: muscles ?? this.muscles,
      selectedBodyPartIds: selectedBodyPartIds ?? this.selectedBodyPartIds,
      selectedEquipmentIds: selectedEquipmentIds ?? this.selectedEquipmentIds,
      selectedExerciseCategoryIds:
          selectedExerciseCategoryIds ?? this.selectedExerciseCategoryIds,
      selectedExerciseTypeIds:
          selectedExerciseTypeIds ?? this.selectedExerciseTypeIds,
      selectedMuscleIds: selectedMuscleIds ?? this.selectedMuscleIds,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      recommendedWorkout: recommendedWorkout ?? this.recommendedWorkout,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bodyParts,
    equipments,
    exerciseCategories,
    exerciseTypes,
    muscles,
    selectedBodyPartIds,
    selectedEquipmentIds,
    selectedExerciseCategoryIds,
    selectedExerciseTypeIds,
    selectedMuscleIds,
    selectedLocation,
    recommendedWorkout,
    errorMessage,
  ];
}
