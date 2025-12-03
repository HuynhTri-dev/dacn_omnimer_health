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
    final durationMinutes = summary?.totalDuration ?? 0;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
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
