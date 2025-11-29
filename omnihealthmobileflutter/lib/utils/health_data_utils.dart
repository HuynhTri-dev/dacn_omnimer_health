import 'package:health/health.dart' as health_pkg;
import '../../domain/entities/health_connect_entity.dart';

class HealthDataUtils {
  static List<health_pkg.HealthDataType> mapToHealthDataTypes(
    List<HealthDataType>? types,
  ) {
    if (types == null || types.isEmpty) {
      return [
        health_pkg.HealthDataType.STEPS,
        health_pkg.HealthDataType.DISTANCE_DELTA,
        health_pkg.HealthDataType.ACTIVE_ENERGY_BURNED,
        health_pkg.HealthDataType.HEART_RATE,
        health_pkg.HealthDataType.RESTING_HEART_RATE,
        health_pkg.HealthDataType.SLEEP_IN_BED,
        health_pkg.HealthDataType.SLEEP_ASLEEP,
        health_pkg.HealthDataType.SLEEP_DEEP,
        health_pkg.HealthDataType.SLEEP_REM,
        health_pkg.HealthDataType.EXERCISE_TIME,
      ];
    }

    final mappedTypes = <health_pkg.HealthDataType>[];
    for (final type in types) {
      switch (type) {
        case HealthDataType.steps:
          mappedTypes.add(health_pkg.HealthDataType.STEPS);
          break;
        case HealthDataType.distance:
          mappedTypes.add(health_pkg.HealthDataType.DISTANCE_DELTA);
          break;
        case HealthDataType.calories:
          mappedTypes.add(health_pkg.HealthDataType.ACTIVE_ENERGY_BURNED);
          break;
        case HealthDataType.activeMinutes:
          mappedTypes.add(health_pkg.HealthDataType.EXERCISE_TIME);
          break;
        case HealthDataType.heartRate:
          mappedTypes.add(health_pkg.HealthDataType.HEART_RATE);
          break;
        case HealthDataType.heartRateRest:
          mappedTypes.add(health_pkg.HealthDataType.RESTING_HEART_RATE);
          break;
        case HealthDataType.heartRateMax:
          mappedTypes.add(health_pkg.HealthDataType.HEART_RATE);
          break;
        case HealthDataType.sleepDuration:
        case HealthDataType.sleepQuality:
          mappedTypes.addAll([
            health_pkg.HealthDataType.SLEEP_IN_BED,
            health_pkg.HealthDataType.SLEEP_ASLEEP,
            health_pkg.HealthDataType.SLEEP_DEEP,
            health_pkg.HealthDataType.SLEEP_REM,
          ]);
          break;
        case HealthDataType.stressLevel:
          // Not supported in health package v13.2.1
          break;
      }
    }

    return mappedTypes;
  }

  static List<HealthConnectData> processHealthData(
    List<health_pkg.HealthDataPoint> healthData,
  ) {
    final groupedData = <DateTime, List<health_pkg.HealthDataPoint>>{};

    for (final point in healthData) {
      final date = DateTime(
        point.dateFrom.year,
        point.dateFrom.month,
        point.dateFrom.day,
      );
      groupedData.putIfAbsent(date, () => []).add(point);
    }

    return groupedData.entries.map((entry) {
      final date = entry.key;
      final points = entry.value;

      int? steps;
      double? distance;
      int? calories;
      int? activeMinutes;
      int? heartRateAvg;
      int? heartRateRest;
      double? sleepDuration;
      double? sleepQuality;
      int? stressLevel;

      for (final point in points) {
        final value = point.value;

        if (value is health_pkg.NumericHealthValue) {
          final numVal = value.numericValue;

          switch (point.type) {
            case health_pkg.HealthDataType.STEPS:
              steps = (steps ?? 0) + numVal.toInt();
              break;
            case health_pkg.HealthDataType.DISTANCE_DELTA:
              distance = (distance ?? 0) + numVal.toDouble();
              break;
            case health_pkg.HealthDataType.ACTIVE_ENERGY_BURNED:
              calories = (calories ?? 0) + numVal.toInt();
              break;
            case health_pkg.HealthDataType.EXERCISE_TIME:
              activeMinutes = (activeMinutes ?? 0) + numVal.toInt();
              break;
            case health_pkg.HealthDataType.HEART_RATE:
              heartRateAvg = numVal.toInt();
              break;
            case health_pkg.HealthDataType.RESTING_HEART_RATE:
              heartRateRest = numVal.toInt();
              break;
            case health_pkg.HealthDataType.SLEEP_ASLEEP:
            case health_pkg.HealthDataType.SLEEP_DEEP:
            case health_pkg.HealthDataType.SLEEP_REM:
              sleepDuration = (sleepDuration ?? 0) + (numVal.toDouble() / 60);
              break;
            default:
              break;
          }
        }
      }

      return HealthConnectData(
        date: date,
        steps: steps,
        distance: distance,
        caloriesBurned: calories,
        activeMinutes: activeMinutes != null
            ? (activeMinutes / 60).round()
            : null,
        heartRateAvg: heartRateAvg,
        heartRateRest: heartRateRest,
        heartRateMax: null,
        sleepDuration: sleepDuration,
        sleepQuality: sleepQuality,
        stressLevel: stressLevel,
      );
    }).toList();
  }

  static List<HealthConnectWorkoutData> processWorkoutData(
    List<health_pkg.HealthDataPoint> workoutData,
  ) {
    return workoutData.map((point) => convertToWorkoutEntity(point)).toList();
  }

  static HealthConnectWorkoutData convertToWorkoutEntity(
    health_pkg.HealthDataPoint point,
  ) {
    final value = point.value;
    int? calories;
    double? distance;
    String? workoutType;

    if (value is health_pkg.WorkoutHealthValue) {
      calories = value.totalEnergyBurned;
      distance = value.totalDistance != null
          ? (value.totalDistance! / 1000)
          : null;
      workoutType = value.workoutActivityType.name;
    }

    return HealthConnectWorkoutData(
      date: point.dateFrom,
      duration: point.dateTo.difference(point.dateFrom),
      heartRateAvg: null,
      heartRateMax: null,
      caloriesBurned: calories,
      distance: distance,
      workoutId: point.uuid,
      workoutType: workoutType,
    );
  }
}
