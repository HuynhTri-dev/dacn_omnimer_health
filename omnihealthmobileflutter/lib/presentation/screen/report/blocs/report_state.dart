import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<WorkoutLogEntity> workoutLogs;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.workoutLogs = const [],
    this.errorMessage,
  });

  ReportState copyWith({
    ReportStatus? status,
    List<WorkoutLogEntity>? workoutLogs,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      workoutLogs: workoutLogs ?? this.workoutLogs,
      errorMessage: errorMessage,
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
  List<Object?> get props => [status, workoutLogs, errorMessage];
}

