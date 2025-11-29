import 'dart:async';
import '../entities/health_connect_entity.dart';

abstract class HealthKitConnectRepository {
  /// Check if HealthKit is available on the device
  Future<bool> isHealthKitAvailable();

  /// Request permissions for HealthKit data types
  Future<bool> requestPermissions();

  /// Check if permissions are granted
  Future<bool> hasPermissions();

  /// Get health data for a specific date range
  Future<List<HealthConnectData>> getHealthData({
    DateTime? startDate,
    DateTime? endDate,
    List<HealthDataType>? types,
  });

  /// Get today's health data
  Future<HealthConnectData?> getTodayHealthData();

  /// Get workout sessions for a specific date range
  Future<List<HealthConnectWorkoutData>> getWorkoutData({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get workout data for a specific workout session
  Future<HealthConnectWorkoutData?> getWorkoutSession(String workoutId);

  /// Start a new workout session
  Future<String> startWorkoutSession({
    required String workoutType,
    Map<String, dynamic>? metadata,
  });

  /// Stop a workout session
  Future<void> stopWorkoutSession(String workoutId);

  /// Sync health data to backend server
  Future<bool> syncHealthDataToBackend({
    List<HealthConnectData>? healthData,
    List<HealthConnectWorkoutData>? workoutData,
  });

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp();

  /// Save last sync timestamp
  Future<void> saveLastSyncTimestamp(DateTime timestamp);

  /// Stream of health data updates
  Stream<List<HealthConnectData>> get healthDataStream;

  /// Stream of workout session updates
  Stream<List<HealthConnectWorkoutData>> get workoutDataStream;
}
