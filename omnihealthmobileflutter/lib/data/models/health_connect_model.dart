import '../../domain/entities/health_connect_entity.dart';

class HealthConnectDataModel {
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
  final int? stressLevel;

  const HealthConnectDataModel({
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
    this.stressLevel,
  });

  factory HealthConnectDataModel.fromJson(Map<String, dynamic> json) {
    return HealthConnectDataModel(
      date: DateTime.parse(json['date']),
      steps: json['steps']?.toInt(),
      distance: json['distance']?.toDouble(),
      caloriesBurned: json['caloriesBurned']?.toInt(),
      activeMinutes: json['activeMinutes']?.toInt(),
      heartRateAvg: json['heartRateAvg']?.toInt(),
      heartRateRest: json['heartRateRest']?.toInt(),
      heartRateMax: json['heartRateMax']?.toInt(),
      sleepDuration: json['sleepDuration']?.toDouble(),
      sleepQuality: json['sleepQuality']?.toDouble(),
      stressLevel: json['stressLevel']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'activeMinutes': activeMinutes,
      'heartRateAvg': heartRateAvg,
      'heartRateRest': heartRateRest,
      'heartRateMax': heartRateMax,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
    };
  }

  HealthConnectData toEntity() {
    return HealthConnectData(
      date: date,
      steps: steps,
      distance: distance,
      caloriesBurned: caloriesBurned,
      activeMinutes: activeMinutes,
      heartRateAvg: heartRateAvg,
      heartRateRest: heartRateRest,
      heartRateMax: heartRateMax,
      sleepDuration: sleepDuration,
      sleepQuality: sleepQuality,
      stressLevel: stressLevel,
    );
  }

  factory HealthConnectDataModel.fromEntity(HealthConnectData entity) {
    return HealthConnectDataModel(
      date: entity.date,
      steps: entity.steps,
      distance: entity.distance,
      caloriesBurned: entity.caloriesBurned,
      activeMinutes: entity.activeMinutes,
      heartRateAvg: entity.heartRateAvg,
      heartRateRest: entity.heartRateRest,
      heartRateMax: entity.heartRateMax,
      sleepDuration: entity.sleepDuration,
      sleepQuality: entity.sleepQuality,
      stressLevel: entity.stressLevel,
    );
  }

  Map<String, dynamic> toWatchLogPayload() {
    return {
      'deviceType': 'Health Connect',
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'caloriesActive': caloriesBurned,
      'activeMinutes': activeMinutes,
      'heartRateAvg': heartRateAvg,
      'heartRateRest': heartRateRest,
      'heartRateMax': heartRateMax,
      'sleepDuration': sleepDuration,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
    };
  }
}

class HealthConnectWorkoutDataModel {
  final DateTime date;
  final Duration duration;
  final int? heartRateAvg;
  final int? heartRateMax;
  final int? caloriesBurned;
  final double? distance;
  final String? workoutId;
  final String? workoutType;

  const HealthConnectWorkoutDataModel({
    required this.date,
    required this.duration,
    this.heartRateAvg,
    this.heartRateMax,
    this.caloriesBurned,
    this.distance,
    this.workoutId,
    this.workoutType,
  });

  factory HealthConnectWorkoutDataModel.fromJson(Map<String, dynamic> json) {
    return HealthConnectWorkoutDataModel(
      date: DateTime.parse(json['date']),
      duration: Duration(milliseconds: json['duration'] ?? 0),
      heartRateAvg: json['heartRateAvg']?.toInt(),
      heartRateMax: json['heartRateMax']?.toInt(),
      caloriesBurned: json['caloriesBurned']?.toInt(),
      distance: json['distance']?.toDouble(),
      workoutId: json['workoutId'],
      workoutType: json['workoutType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'duration': duration.inMilliseconds,
      'heartRateAvg': heartRateAvg,
      'heartRateMax': heartRateMax,
      'caloriesBurned': caloriesBurned,
      'distance': distance,
      'workoutId': workoutId,
      'workoutType': workoutType,
    };
  }

  HealthConnectWorkoutData toEntity() {
    return HealthConnectWorkoutData(
      date: date,
      duration: duration,
      heartRateAvg: heartRateAvg,
      heartRateMax: heartRateMax,
      caloriesBurned: caloriesBurned,
      distance: distance,
      workoutId: workoutId,
      workoutType: workoutType,
    );
  }

  factory HealthConnectWorkoutDataModel.fromEntity(
    HealthConnectWorkoutData entity,
  ) {
    return HealthConnectWorkoutDataModel(
      date: entity.date,
      duration: entity.duration,
      heartRateAvg: entity.heartRateAvg,
      heartRateMax: entity.heartRateMax,
      caloriesBurned: entity.caloriesBurned,
      distance: entity.distance,
      workoutId: entity.workoutId,
      workoutType: entity.workoutType,
    );
  }

  Map<String, dynamic> toWatchLogPayload() {
    return {
      'workoutId': workoutId,
      'deviceType': 'Health Connect',
      'date': date.toIso8601String(),
      'activeMinutes': duration.inMinutes,
      'caloriesActive': caloriesBurned,
      'heartRateAvg': heartRateAvg,
      'heartRateMax': heartRateMax,
      'distance': distance,
    };
  }
}
