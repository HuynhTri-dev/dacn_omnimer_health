import 'package:omnihealthmobileflutter/domain/entities/workout/workout_stats_entity.dart';

/// Model for Weekly Workout Stats
class WeeklyWorkoutStatsModel {
  final String dayOfWeek;
  final double hours;
  final int workoutCount;

  WeeklyWorkoutStatsModel({
    required this.dayOfWeek,
    required this.hours,
    required this.workoutCount,
  });

  factory WeeklyWorkoutStatsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyWorkoutStatsModel(
      dayOfWeek: json['dayOfWeek'] ?? '',
      hours: (json['hours'] ?? 0).toDouble(),
      workoutCount: json['workoutCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'hours': hours,
      'workoutCount': workoutCount,
    };
  }

  WeeklyWorkoutStatsEntity toEntity() {
    return WeeklyWorkoutStatsEntity(
      dayOfWeek: dayOfWeek,
      hours: hours,
      workoutCount: workoutCount,
    );
  }
}

/// Model for Workout Stats
class WorkoutStatsModel {
  final List<WeeklyWorkoutStatsModel> weeklyStats;
  final double totalHoursThisWeek;
  final int totalWorkoutsThisWeek;

  WorkoutStatsModel({
    required this.weeklyStats,
    required this.totalHoursThisWeek,
    required this.totalWorkoutsThisWeek,
  });

  factory WorkoutStatsModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatsModel(
      weeklyStats: (json['weeklyStats'] as List?)
              ?.map((stat) => WeeklyWorkoutStatsModel.fromJson(stat))
              .toList() ??
          [],
      totalHoursThisWeek: (json['totalHoursThisWeek'] ?? 0).toDouble(),
      totalWorkoutsThisWeek: json['totalWorkoutsThisWeek'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyStats': weeklyStats.map((stat) => stat.toJson()).toList(),
      'totalHoursThisWeek': totalHoursThisWeek,
      'totalWorkoutsThisWeek': totalWorkoutsThisWeek,
    };
  }

  WorkoutStatsEntity toEntity() {
    return WorkoutStatsEntity(
      weeklyStats: weeklyStats.map((stat) => stat.toEntity()).toList(),
      totalHoursThisWeek: totalHoursThisWeek,
      totalWorkoutsThisWeek: totalWorkoutsThisWeek,
    );
  }
}

