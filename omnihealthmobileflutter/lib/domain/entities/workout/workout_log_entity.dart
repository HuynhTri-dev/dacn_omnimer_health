import 'package:equatable/equatable.dart';

/// Entity for a completed set in workout log
class WorkoutLogSetEntity extends Equatable {
  final String? id;
  final int setOrder;
  final int? reps;
  final double? weight;
  final int? duration; // seconds
  final double? distance; // meters
  final int? restAfterSetSeconds;
  final String? notes;
  final bool isCompleted; // Maps to 'done'

  const WorkoutLogSetEntity({
    this.id,
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.restAfterSetSeconds,
    this.notes,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    setOrder,
    reps,
    weight,
    duration,
    distance,
    restAfterSetSeconds,
    notes,
    isCompleted,
  ];
}

/// Entity for device data in workout log (per exercise)
class WorkoutDeviceDataEntity extends Equatable {
  final String? id;
  final double? heartRateAvg;
  final double? heartRateMax;
  final double? caloriesBurned;

  const WorkoutDeviceDataEntity({
    this.id,
    this.heartRateAvg,
    this.heartRateMax,
    this.caloriesBurned,
  });

  @override
  List<Object?> get props => [id, heartRateAvg, heartRateMax, caloriesBurned];
}

/// Entity for an exercise in workout log
class WorkoutLogExerciseEntity extends Equatable {
  final String? id; // Workout Detail ID
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type;
  final List<WorkoutLogSetEntity> sets;
  final double? durationMin; // total duration for exercise
  final WorkoutDeviceDataEntity? deviceData;
  final bool
  isCompleted; // Helper for UI, not strictly in backend model but useful

  const WorkoutLogExerciseEntity({
    this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
    this.durationMin,
    this.deviceData,
    this.isCompleted = false,
  });

  int get completedSetsCount => sets.where((s) => s.isCompleted).length;
  int get totalSetsCount => sets.length;

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    exerciseName,
    exerciseImageUrl,
    type,
    sets,
    durationMin,
    deviceData,
    isCompleted,
  ];
}

/// Entity for workout summary
class WorkoutSummaryEntity extends Equatable {
  final double? heartRateAvgAllWorkout;
  final double? heartRateMaxAllWorkout;
  final int? totalSets;
  final int? totalReps;
  final double? totalWeight;
  final int? totalDuration;
  final double? totalCalories;
  final double? totalDistance;

  const WorkoutSummaryEntity({
    this.heartRateAvgAllWorkout,
    this.heartRateMaxAllWorkout,
    this.totalSets,
    this.totalReps,
    this.totalWeight,
    this.totalDuration,
    this.totalCalories,
    this.totalDistance,
  });

  @override
  List<Object?> get props => [
    heartRateAvgAllWorkout,
    heartRateMaxAllWorkout,
    totalSets,
    totalReps,
    totalWeight,
    totalDuration,
    totalCalories,
    totalDistance,
  ];
}

/// Entity for workout log
class WorkoutLogEntity extends Equatable {
  final String? id;
  final String userId;
  final String? healthProfileId;
  final String? templateId;
  final String workoutName; // Derived or from template
  final List<WorkoutLogExerciseEntity> exercises; // Maps to workoutDetail
  final DateTime startedAt; // Maps to timeStart
  final DateTime?
  finishedAt; // Helper, maybe not in backend directly if only timeStart is stored? Backend has timestamps.
  final String? notes;
  final WorkoutSummaryEntity? summary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutLogEntity({
    this.id,
    required this.userId,
    this.healthProfileId,
    this.templateId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    this.finishedAt,
    this.notes,
    this.summary,
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
    final durationSeconds = summary?.totalDuration ?? 0;
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
    userId,
    healthProfileId,
    templateId,
    workoutName,
    exercises,
    startedAt,
    finishedAt,
    notes,
    summary,
    createdAt,
    updatedAt,
  ];
}
