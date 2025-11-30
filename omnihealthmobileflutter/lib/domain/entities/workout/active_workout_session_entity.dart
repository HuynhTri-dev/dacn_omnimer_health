import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

/// Entity representing a set being performed during an active workout
class ActiveSetEntity extends Equatable {
  final String? id; // Set ID from server
  final int setOrder;
  final int? targetReps;
  final double? targetWeight;
  final int? targetDuration;
  final double? targetDistance;
  final int? restAfterSetSeconds;

  // Actual performed values
  final int? actualReps;
  final double? actualWeight;
  final int? actualDuration;
  final double? actualDistance;

  final bool isCompleted;
  final DateTime? completedAt;

  const ActiveSetEntity({
    this.id,
    required this.setOrder,
    this.targetReps,
    this.targetWeight,
    this.targetDuration,
    this.targetDistance,
    this.restAfterSetSeconds,
    this.actualReps,
    this.actualWeight,
    this.actualDuration,
    this.actualDistance,
    this.isCompleted = false,
    this.completedAt,
  });

  ActiveSetEntity copyWith({
    String? id,
    int? setOrder,
    int? targetReps,
    double? targetWeight,
    int? targetDuration,
    double? targetDistance,
    int? restAfterSetSeconds,
    int? actualReps,
    double? actualWeight,
    int? actualDuration,
    double? actualDistance,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ActiveSetEntity(
      id: id ?? this.id,
      setOrder: setOrder ?? this.setOrder,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDuration: targetDuration ?? this.targetDuration,
      targetDistance: targetDistance ?? this.targetDistance,
      restAfterSetSeconds: restAfterSetSeconds ?? this.restAfterSetSeconds,
      actualReps: actualReps ?? this.actualReps,
      actualWeight: actualWeight ?? this.actualWeight,
      actualDuration: actualDuration ?? this.actualDuration,
      actualDistance: actualDistance ?? this.actualDistance,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Create from template set
  factory ActiveSetEntity.fromTemplateSet(
    WorkoutTemplateSetEntity templateSet,
  ) {
    return ActiveSetEntity(
      setOrder: templateSet.setOrder,
      targetReps: templateSet.reps,
      targetWeight: templateSet.weight,
      targetDuration: templateSet.duration,
      targetDistance: templateSet.distance,
      restAfterSetSeconds: templateSet.restAfterSetSeconds,
      actualReps: templateSet.reps,
      actualWeight: templateSet.weight,
      actualDuration: templateSet.duration,
      actualDistance: templateSet.distance,
    );
  }

  @override
  List<Object?> get props => [
    id,
    setOrder,
    targetReps,
    targetWeight,
    targetDuration,
    targetDistance,
    restAfterSetSeconds,
    actualReps,
    actualWeight,
    actualDuration,
    actualDistance,
    isCompleted,
    completedAt,
  ];
}

/// Entity representing an exercise being performed during an active workout
class ActiveExerciseEntity extends Equatable {
  final String? id; // Workout Detail ID (from server)
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type;
  final List<ActiveSetEntity> sets;
  final bool isExpanded;

  const ActiveExerciseEntity({
    this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
    this.isExpanded = true,
  });

  /// Number of completed sets
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  /// Total number of sets
  int get totalSetsCount => sets.length;

  /// Whether all sets are completed
  bool get isCompleted => sets.isNotEmpty && sets.every((s) => s.isCompleted);

  ActiveExerciseEntity copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? exerciseImageUrl,
    String? type,
    List<ActiveSetEntity>? sets,
    bool? isExpanded,
  }) {
    return ActiveExerciseEntity(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImageUrl: exerciseImageUrl ?? this.exerciseImageUrl,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  /// Create from template detail
  factory ActiveExerciseEntity.fromTemplateDetail(
    WorkoutTemplateDetailEntity templateDetail,
  ) {
    return ActiveExerciseEntity(
      exerciseId: templateDetail.exerciseId,
      exerciseName: templateDetail.exerciseName,
      exerciseImageUrl: templateDetail.exerciseImageUrl,
      type: templateDetail.type,
      sets: templateDetail.sets
          .map((s) => ActiveSetEntity.fromTemplateSet(s))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    exerciseName,
    exerciseImageUrl,
    type,
    sets,
    isExpanded,
  ];
}

/// Entity representing an active workout session
class ActiveWorkoutSessionEntity extends Equatable {
  final String? workoutId; // ID from server
  final String? templateId;
  final String workoutName;
  final List<ActiveExerciseEntity> exercises;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Duration elapsedTime;
  final bool isPaused;

  const ActiveWorkoutSessionEntity({
    this.workoutId,
    this.templateId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    this.finishedAt,
    this.elapsedTime = Duration.zero,
    this.isPaused = false,
  });

  /// Number of completed exercises
  int get completedExercisesCount =>
      exercises.where((e) => e.isCompleted).length;

  /// Total number of exercises
  int get totalExercisesCount => exercises.length;

  /// Total completed sets across all exercises
  int get totalCompletedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSetsCount);

  /// Total sets across all exercises
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSetsCount);

  /// Whether all exercises are completed
  bool get isCompleted =>
      exercises.isNotEmpty && exercises.every((e) => e.isCompleted);

  /// Progress percentage (0.0 - 1.0)
  double get progress => totalSets > 0 ? totalCompletedSets / totalSets : 0.0;

  ActiveWorkoutSessionEntity copyWith({
    String? workoutId,
    String? templateId,
    String? workoutName,
    List<ActiveExerciseEntity>? exercises,
    DateTime? startedAt,
    DateTime? finishedAt,
    Duration? elapsedTime,
    bool? isPaused,
  }) {
    return ActiveWorkoutSessionEntity(
      workoutId: workoutId ?? this.workoutId,
      templateId: templateId ?? this.templateId,
      workoutName: workoutName ?? this.workoutName,
      exercises: exercises ?? this.exercises,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  /// Create from workout template
  factory ActiveWorkoutSessionEntity.fromTemplate(
    WorkoutTemplateEntity template,
  ) {
    return ActiveWorkoutSessionEntity(
      templateId: template.id,
      workoutName: template.name,
      exercises: template.workOutDetail
          .map((d) => ActiveExerciseEntity.fromTemplateDetail(d))
          .toList(),
      startedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    workoutId,
    templateId,
    workoutName,
    exercises,
    startedAt,
    finishedAt,
    elapsedTime,
    isPaused,
  ];
}
