import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<WorkoutLogEntity> workoutLogs;
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
    List<WorkoutLogEntity>? workoutLogs,
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

  /// Get total duration in seconds
  int get totalDurationSeconds =>
      workoutLogs.fold(0, (sum, log) => sum + log.durationSeconds);

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDurationSeconds ~/ 3600;
    final minutes = (totalDurationSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get total sets completed
  int get totalSetsCompleted =>
      workoutLogs.fold(0, (sum, log) => sum + log.totalCompletedSets);

  /// Get total exercises completed
  int get totalExercisesCompleted =>
      workoutLogs.fold(0, (sum, log) => sum + log.completedExercisesCount);

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

