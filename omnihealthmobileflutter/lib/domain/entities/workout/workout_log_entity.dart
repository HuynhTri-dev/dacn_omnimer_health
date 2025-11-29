import 'package:equatable/equatable.dart';

/// Entity for a completed set in workout log
class WorkoutLogSetEntity extends Equatable {
  final int setOrder;
  final int? reps;
  final double? weight;
  final int? duration;
  final double? distance;
  final bool isCompleted;
  final DateTime? completedAt;

  const WorkoutLogSetEntity({
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.isCompleted = false,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    setOrder,
    reps,
    weight,
    duration,
    distance,
    isCompleted,
    completedAt,
  ];
}

/// Entity for an exercise in workout log
class WorkoutLogExerciseEntity extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type;
  final List<WorkoutLogSetEntity> sets;
  final bool isCompleted;

  const WorkoutLogExerciseEntity({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
    this.isCompleted = false,
  });

  int get completedSetsCount => sets.where((s) => s.isCompleted).length;
  int get totalSetsCount => sets.length;

  @override
  List<Object?> get props => [
    exerciseId,
    exerciseName,
    exerciseImageUrl,
    type,
    sets,
    isCompleted,
  ];
}

/// Entity for workout log
class WorkoutLogEntity extends Equatable {
  final String? id;
  final String? templateId;
  final String workoutName;
  final List<WorkoutLogExerciseEntity> exercises;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int durationSeconds;
  final String? notes;
  final String status; // 'in_progress', 'completed', 'cancelled'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutLogEntity({
    this.id,
    this.templateId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    this.finishedAt,
    required this.durationSeconds,
    this.notes,
    this.status = 'completed',
    this.createdAt,
    this.updatedAt,
  });

  int get totalCompletedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSetsCount);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSetsCount);

  int get completedExercisesCount =>
      exercises.where((e) => e.isCompleted).length;

  int get totalExercisesCount => exercises.length;

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  List<Object?> get props => [
    id,
    templateId,
    workoutName,
    exercises,
    startedAt,
    finishedAt,
    durationSeconds,
    notes,
    status,
    createdAt,
    updatedAt,
  ];
}
