import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/workout_frequency_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_stats_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

enum WorkoutHomeStatus { initial, loading, loaded, error }

class WorkoutHomeState extends Equatable {
  final WorkoutHomeStatus status;
  final WorkoutStatsEntity? weeklyStats;
  final List<WorkoutFrequencyEntity>? workoutFrequency;
  final List<WorkoutTemplateEntity> templates;
  final String? errorMessage;

  const WorkoutHomeState({
    this.status = WorkoutHomeStatus.initial,
    this.weeklyStats,
    this.workoutFrequency,
    this.templates = const [],
    this.errorMessage,
  });

  WorkoutHomeState copyWith({
    WorkoutHomeStatus? status,
    WorkoutStatsEntity? weeklyStats,
    List<WorkoutFrequencyEntity>? workoutFrequency,
    List<WorkoutTemplateEntity>? templates,
    String? errorMessage,
  }) {
    return WorkoutHomeState(
      status: status ?? this.status,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      templates: templates ?? this.templates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    weeklyStats,
    workoutFrequency,
    templates,
    errorMessage,
  ];
}
