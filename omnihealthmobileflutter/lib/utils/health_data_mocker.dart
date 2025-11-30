import 'dart:math';
import 'package:health/health.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

class HealthDataMocker {
  final Health _health;
  final Random _random = Random();

  HealthDataMocker(this._health);

  /// Generates and writes mock data to Health Connect for a specific time range.
  /// Based on 'Scenario A: Healthy & Active' from RANGES_DATA.md
  Future<void> writeMockSessionData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final durationMinutes = endTime.difference(startTime).inMinutes;
      if (durationMinutes <= 0) return;

      logger.i(
        'Generating mock Health Connect data for $durationMinutes minutes...',
      );

      int totalSteps = 0;
      double totalCalories = 0;
      double totalDistance = 0;

      // Simulate a workout curve: Warmup -> Peak -> Cooldown
      for (int i = 0; i < durationMinutes; i++) {
        final pointTime = startTime.add(Duration(minutes: i));
        final progress = i / durationMinutes;

        // Heart Rate Curve: Starts at ~80, peaks at ~160, ends at ~100
        double baseHR;
        if (progress < 0.2) {
          // Warmup
          baseHR = 80 + (progress * 5 * 40); // 80 -> 120
        } else if (progress < 0.8) {
          // Main workout (Peak)
          baseHR = 130 + _random.nextInt(30).toDouble(); // 130-160
        } else {
          // Cooldown
          baseHR = 140 - ((progress - 0.8) * 5 * 40); // 140 -> 100
        }

        // Add some noise
        final hrValue = baseHR + (_random.nextDouble() * 10 - 5);

        await _health.writeHealthData(
          value: hrValue,
          type: HealthDataType.HEART_RATE,
          startTime: pointTime,
          endTime: pointTime.add(const Duration(seconds: 59)),
        );

        // Steps & Distance (assuming running/active)
        // ~100-160 steps per min during peak
        int steps = 0;
        if (progress > 0.1 && progress < 0.9) {
          steps = 100 + _random.nextInt(60);
          totalSteps += steps;

          await _health.writeHealthData(
            value: steps.toDouble(),
            type: HealthDataType.STEPS,
            startTime: pointTime,
            endTime: pointTime.add(const Duration(seconds: 59)),
          );

          // Distance ~0.8m per step
          final dist = steps * 0.8;
          totalDistance += dist;
          await _health.writeHealthData(
            value: dist,
            type: HealthDataType.DISTANCE_DELTA,
            startTime: pointTime,
            endTime: pointTime.add(const Duration(seconds: 59)),
          );
        }

        // Calories (Active)
        // ~5-15 kcal/min depending on intensity
        final kcal = (hrValue - 60) * 0.15; // Simple formula
        totalCalories += kcal;
        await _health.writeHealthData(
          value: kcal,
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          startTime: pointTime,
          endTime: pointTime.add(const Duration(seconds: 59)),
        );
      }

      logger.i(
        'Mock data written successfully: Steps=$totalSteps, Kcal=${totalCalories.toStringAsFixed(1)}, Dist=${totalDistance.toStringAsFixed(1)}m',
      );
    } catch (e) {
      logger.e('Error writing mock health data: $e');
    }
  }
}
