import 'package:equatable/equatable.dart';

class HealthConnectData extends Equatable {
  final DateTime date;
  final int? steps;
  final double? distance;
  final int? caloriesBurned;
  final int? activeMinutes;
  final int? heartRateAvg;
  final int? heartRateRest;
  final int? heartRateMax;
  final double? sleepDuration;
  final double? sleepQuality;
  final double? vo2max;
  final int? stressLevel;

  const HealthConnectData({
    required this.date,
    this.steps,
    this.distance,
    this.caloriesBurned,
    this.activeMinutes,
    this.heartRateAvg,
    this.heartRateRest,
    this.heartRateMax,
    this.sleepDuration,
    this.sleepQuality,
    this.vo2max,
    this.stressLevel,
  });

  @override
  List<Object?> get props => [
    date,
    steps,
    distance,
    caloriesBurned,
    activeMinutes,
    heartRateAvg,
    heartRateRest,
    heartRateMax,
    sleepDuration,
    sleepQuality,
    vo2max,
    stressLevel,
  ];

  HealthConnectData copyWith({
    DateTime? date,
    int? steps,
    double? distance,
    int? caloriesBurned,
    int? activeMinutes,
    int? heartRateAvg,
    int? heartRateRest,
    int? heartRateMax,
    double? sleepDuration,
    double? sleepQuality,
    double? vo2max,
    int? stressLevel,
  }) {
    return HealthConnectData(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateRest: heartRateRest ?? this.heartRateRest,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      vo2max: vo2max ?? this.vo2max,
      stressLevel: stressLevel ?? this.stressLevel,
    );
  }
}

class HealthConnectWorkoutData extends Equatable {
  final DateTime date;
  final Duration duration;
  final int? heartRateAvg;
  final int? heartRateMax;
  final int? caloriesBurned;
  final double? distance;
  final String? workoutId;
  final String? workoutType;

  const HealthConnectWorkoutData({
    required this.date,
    required this.duration,
    this.heartRateAvg,
    this.heartRateMax,
    this.caloriesBurned,
    this.distance,
    this.workoutId,
    this.workoutType,
  });

  @override
  List<Object?> get props => [
    date,
    duration,
    heartRateAvg,
    heartRateMax,
    caloriesBurned,
    distance,
    workoutId,
    workoutType,
  ];

  HealthConnectWorkoutData copyWith({
    DateTime? date,
    Duration? duration,
    int? heartRateAvg,
    int? heartRateMax,
    int? caloriesBurned,
    double? distance,
    String? workoutId,
    String? workoutType,
  }) {
    return HealthConnectWorkoutData(
      date: date ?? this.date,
      duration: duration ?? this.duration,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distance: distance ?? this.distance,
      workoutId: workoutId ?? this.workoutId,
      workoutType: workoutType ?? this.workoutType,
    );
  }
}

enum HealthDataType {
  steps,
  distance,
  calories,
  activeMinutes,
  heartRate,
  heartRateRest,
  heartRateMax,
  sleepDuration,
  sleepQuality,
  stressLevel,
}
