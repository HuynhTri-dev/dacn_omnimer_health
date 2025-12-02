import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

/// Entity for workout log summary (list view)
class WorkoutLogSummaryEntity extends Equatable {
  final String? id;
  final String userId;
  final String? templateId;
  final String workoutName;
  final WorkoutSummaryEntity? summary;
  // These might be missing in the summary view, but useful if present
  final DateTime? startedAt;

  const WorkoutLogSummaryEntity({
    this.id,
    required this.userId,
    this.templateId,
    required this.workoutName,
    this.summary,
    this.startedAt,
  });

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
    templateId,
    workoutName,
    summary,
    startedAt,
  ];
}
