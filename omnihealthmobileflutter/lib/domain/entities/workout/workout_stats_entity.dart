import 'package:equatable/equatable.dart';

/// Entity for Weekly Workout Stats (for the chart)
class WeeklyWorkoutStatsEntity extends Equatable {
  final String dayOfWeek; // Mon, Tue, Wed, etc.
  final double hours; // Total hours worked out on that day
  final int workoutCount; // Number of workouts

  const WeeklyWorkoutStatsEntity({
    required this.dayOfWeek,
    required this.hours,
    required this.workoutCount,
  });

  @override
  List<Object?> get props => [dayOfWeek, hours, workoutCount];
}

/// Entity for Overall Workout Stats
class WorkoutStatsEntity extends Equatable {
  final List<WeeklyWorkoutStatsEntity> weeklyStats;
  final double totalHoursThisWeek;
  final int totalWorkoutsThisWeek;

  const WorkoutStatsEntity({
    required this.weeklyStats,
    required this.totalHoursThisWeek,
    required this.totalWorkoutsThisWeek,
  });

  @override
  List<Object?> get props => [
        weeklyStats,
        totalHoursThisWeek,
        totalWorkoutsThisWeek,
      ];
}

