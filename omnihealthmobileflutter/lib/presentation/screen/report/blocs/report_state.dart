import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_summary_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<WorkoutLogSummaryEntity> workoutLogs;
  final String? errorMessage;

  // Chart data
  final List<CaloriesBurnedEntity> caloriesBurned;
  final List<MuscleDistributionEntity> muscleDistribution;
  final List<GoalProgressEntity> goalProgress;
  final List<WeightProgressEntity> weightProgress;
  final bool isChartLoading;

  const ReportState({
    this.status = ReportStatus.initial,
    this.workoutLogs = const [],
    this.errorMessage,
    this.caloriesBurned = const [],
    this.muscleDistribution = const [],
    this.goalProgress = const [],
    this.weightProgress = const [],
    this.isChartLoading = false,
  });

  ReportState copyWith({
    ReportStatus? status,
    List<WorkoutLogSummaryEntity>? workoutLogs,
    String? errorMessage,
    List<CaloriesBurnedEntity>? caloriesBurned,
    List<MuscleDistributionEntity>? muscleDistribution,
    List<GoalProgressEntity>? goalProgress,
    List<WeightProgressEntity>? weightProgress,
    bool? isChartLoading,
  }) {
    return ReportState(
      status: status ?? this.status,
      workoutLogs: workoutLogs ?? this.workoutLogs,
      errorMessage: errorMessage,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      muscleDistribution: muscleDistribution ?? this.muscleDistribution,
      goalProgress: goalProgress ?? this.goalProgress,
      weightProgress: weightProgress ?? this.weightProgress,
      isChartLoading: isChartLoading ?? this.isChartLoading,
    );
  }

  /// Get total workout count
  int get totalWorkouts => workoutLogs.length;

  /// Get total duration in minutes
  int get totalDurationMinutes => workoutLogs.fold(
    0,
    (sum, log) => sum + (log.summary?.totalDuration ?? 0),
  );

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDurationMinutes ~/ 60;
    final minutes = totalDurationMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get total calories burned
  double get totalCalories => workoutLogs.fold(
    0.0,
    (sum, log) => sum + (log.summary?.totalCalories ?? 0),
  );

  /// Get average heart rate across all workouts
  double get avgHeartRate {
    if (workoutLogs.isEmpty) return 0;
    final logsWithHr = workoutLogs
        .where((log) => log.summary?.heartRateAvgAllWorkout != null)
        .toList();
    if (logsWithHr.isEmpty) return 0;

    final totalAvgHr = logsWithHr.fold(
      0.0,
      (sum, log) => sum + (log.summary!.heartRateAvgAllWorkout!),
    );
    return totalAvgHr / logsWithHr.length;
  }

  /// Get max heart rate across all workouts
  double get maxHeartRate {
    if (workoutLogs.isEmpty) return 0;
    final logsWithHr = workoutLogs
        .where((log) => log.summary?.heartRateMaxAllWorkout != null)
        .toList();
    if (logsWithHr.isEmpty) return 0;

    return logsWithHr.fold(
      0.0,
      (max, log) => (log.summary!.heartRateMaxAllWorkout! > max)
          ? log.summary!.heartRateMaxAllWorkout!
          : max,
    );
  }

  /// Get total sets completed
  int get totalSetsCompleted =>
      workoutLogs.fold(0, (sum, log) => sum + (log.summary?.totalSets ?? 0));

  /// Get total exercises completed (Not available in summary, returning 0 or estimated)
  int get totalExercisesCompleted => 0;

  @override
  List<Object?> get props => [
    status,
    workoutLogs,
    errorMessage,
    caloriesBurned,
    muscleDistribution,
    goalProgress,
    weightProgress,
    isChartLoading,
  ];
}
