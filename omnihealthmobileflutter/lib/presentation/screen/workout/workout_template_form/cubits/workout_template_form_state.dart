import 'package:equatable/equatable.dart';

enum WorkoutTemplateFormStatus {
  initial,
  loading,
  editing,
  saving,
  saved,
  error,
}

/// Represents a set in the workout form
class WorkoutSetFormData extends Equatable {
  final int setOrder;
  final int? reps;
  final double? weight;
  final int? duration;
  final double? distance;
  final int? restAfterSetSeconds;
  final String? notes;

  const WorkoutSetFormData({
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.restAfterSetSeconds,
    this.notes,
  });

  WorkoutSetFormData copyWith({
    int? setOrder,
    int? reps,
    double? weight,
    int? duration,
    double? distance,
    int? restAfterSetSeconds,
    String? notes,
  }) {
    return WorkoutSetFormData(
      setOrder: setOrder ?? this.setOrder,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      restAfterSetSeconds: restAfterSetSeconds ?? this.restAfterSetSeconds,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        setOrder,
        reps,
        weight,
        duration,
        distance,
        restAfterSetSeconds,
        notes,
      ];
}

/// Represents an exercise detail in the workout form
class WorkoutExerciseFormData extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type;
  final List<WorkoutSetFormData> sets;

  const WorkoutExerciseFormData({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
  });

  WorkoutExerciseFormData copyWith({
    String? exerciseId,
    String? exerciseName,
    String? exerciseImageUrl,
    String? type,
    List<WorkoutSetFormData>? sets,
  }) {
    return WorkoutExerciseFormData(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImageUrl: exerciseImageUrl ?? this.exerciseImageUrl,
      type: type ?? this.type,
      sets: sets ?? this.sets,
    );
  }

  @override
  List<Object?> get props => [
        exerciseId,
        exerciseName,
        exerciseImageUrl,
        type,
        sets,
      ];
}

class WorkoutTemplateFormState extends Equatable {
  final WorkoutTemplateFormStatus status;
  final String templateId;
  final String name;
  final String description;
  final String? notes;
  final List<String> equipmentIds;
  final List<String> bodyPartIds;
  final List<String> exerciseTypeIds;
  final List<String> exerciseCategoryIds;
  final List<String> muscleIds;
  final String? location;
  final List<WorkoutExerciseFormData> exercises;
  final String? errorMessage;
  final bool isEditMode;

  const WorkoutTemplateFormState({
    this.status = WorkoutTemplateFormStatus.initial,
    this.templateId = '',
    this.name = '',
    this.description = '',
    this.notes,
    this.equipmentIds = const [],
    this.bodyPartIds = const [],
    this.exerciseTypeIds = const [],
    this.exerciseCategoryIds = const [],
    this.muscleIds = const [],
    this.location,
    this.exercises = const [],
    this.errorMessage,
    this.isEditMode = false,
  });

  WorkoutTemplateFormState copyWith({
    WorkoutTemplateFormStatus? status,
    String? templateId,
    String? name,
    String? description,
    String? notes,
    List<String>? equipmentIds,
    List<String>? bodyPartIds,
    List<String>? exerciseTypeIds,
    List<String>? exerciseCategoryIds,
    List<String>? muscleIds,
    String? location,
    List<WorkoutExerciseFormData>? exercises,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return WorkoutTemplateFormState(
      status: status ?? this.status,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      bodyPartIds: bodyPartIds ?? this.bodyPartIds,
      exerciseTypeIds: exerciseTypeIds ?? this.exerciseTypeIds,
      exerciseCategoryIds: exerciseCategoryIds ?? this.exerciseCategoryIds,
      muscleIds: muscleIds ?? this.muscleIds,
      location: location ?? this.location,
      exercises: exercises ?? this.exercises,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        templateId,
        name,
        description,
        notes,
        equipmentIds,
        bodyPartIds,
        exerciseTypeIds,
        exerciseCategoryIds,
        muscleIds,
        location,
        exercises,
        errorMessage,
        isEditMode,
      ];
}

