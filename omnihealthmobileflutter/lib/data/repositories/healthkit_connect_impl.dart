import 'dart:async';
import 'dart:io';
import 'package:health/health.dart' as health_pkg;
import 'package:logger/logger.dart';
import '../../domain/abstracts/healthkit_connect_abs.dart';
import '../../domain/entities/health_connect_entity.dart';
import '../models/health_connect_model.dart';
import '../datasources/watch_log_datasource.dart';
import '../../services/shared_preferences_service.dart';
import '../../utils/health_data_utils.dart';

class HealthKitConnectRepositoryImpl implements HealthKitConnectRepository {
  final health_pkg.Health _health;
  final Logger _logger;
  final WatchLogDataSource _watchLogDataSource;
  final SharedPreferencesService _sharedPreferencesService;

  final StreamController<List<HealthConnectData>> _healthDataController =
      StreamController<List<HealthConnectData>>.broadcast();
  final StreamController<List<HealthConnectWorkoutData>>
  _workoutDataController =
      StreamController<List<HealthConnectWorkoutData>>.broadcast();

  HealthKitConnectRepositoryImpl(
    this._health,
    this._logger,
    this._watchLogDataSource,
    this._sharedPreferencesService,
  );

  @override
  Future<bool> isHealthKitAvailable() async {
    try {
      if (Platform.isIOS) {
        // HealthKit is available on iOS devices (mostly)
        // The health package doesn't have a specific isHealthKitAvailable method that differs much from just checking platform,
        // but we can assume true for iOS if the package is initialized.
        // However, we can check if the device supports HealthKit by trying to request permissions or checking specific capabilities if needed.
        // For now, returning true if iOS is a safe bet for availability of the framework.
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error checking HealthKit availability: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      if (!Platform.isIOS) return false;

      final types = [
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
        health_pkg.HealthDataType.WORKOUT,
      ];

      // HealthKit requires defining read and write permissions separately if needed,
      // but requestAuthorization takes a list of types.
      // The health package handles this.
      final permissions = await _health.requestAuthorization(types);
      _logger.i('HealthKit permissions granted: $permissions');
      return permissions;
    } catch (e) {
      _logger.e('Error requesting HealthKit permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      if (!Platform.isIOS) return false;

      final types = [
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
        health_pkg.HealthDataType.WORKOUT,
      ];

      final hasPermissions = await _health.hasPermissions(types);
      _logger.i('HealthKit has permissions: $hasPermissions');
      return hasPermissions ?? false;
    } catch (e) {
      _logger.e('Error checking HealthKit permissions: $e');
      return false;
    }
  }

  @override
  Future<List<HealthConnectData>> getHealthData({
    DateTime? startDate,
    DateTime? endDate,
    List<HealthDataType>? types,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 1));
      final end = endDate ?? now;

      final healthTypes = HealthDataUtils.mapToHealthDataTypes(types);

      final healthData = await _health.getHealthDataFromTypes(
        types: healthTypes,
        startTime: start,
        endTime: end,
      );

      return HealthDataUtils.processHealthData(healthData);
    } catch (e) {
      _logger.e('Error getting health data: $e');
      return [];
    }
  }

  @override
  Future<HealthConnectData?> getTodayHealthData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      final healthData = await getHealthData(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return healthData.isNotEmpty ? healthData.first : null;
    } catch (e) {
      _logger.e('Error getting today health data: $e');
      return null;
    }
  }

  @override
  Future<List<HealthConnectWorkoutData>> getWorkoutData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 7));
      final end = endDate ?? now;

      final workoutData = await _health.getHealthDataFromTypes(
        types: [health_pkg.HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );

      return HealthDataUtils.processWorkoutData(workoutData);
    } catch (e) {
      _logger.e('Error getting workout data: $e');
      return [];
    }
  }

  @override
  Future<HealthConnectWorkoutData?> getWorkoutSession(String workoutId) async {
    try {
      final workoutData = await _health.getHealthDataFromTypes(
        types: [health_pkg.HealthDataType.WORKOUT],
        startTime: DateTime.now().subtract(const Duration(days: 30)),
        endTime: DateTime.now(),
      );

      final workout = workoutData.firstWhere(
        (data) => data.uuid == workoutId,
        orElse: () => throw Exception('Workout not found'),
      );

      return HealthDataUtils.convertToWorkoutEntity(workout);
    } catch (e) {
      _logger.e('Error getting workout session: $e');
      return null;
    }
  }

  @override
  Future<String> startWorkoutSession({
    required String workoutType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('Starting workout session: $workoutType');
      final workoutId = DateTime.now().millisecondsSinceEpoch.toString();
      return workoutId;
    } catch (e) {
      _logger.e('Error starting workout session: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopWorkoutSession(String workoutId) async {
    try {
      _logger.i('Stopping workout session: $workoutId');
    } catch (e) {
      _logger.e('Error stopping workout session: $e');
      rethrow;
    }
  }

  @override
  Future<bool> syncHealthDataToBackend({
    List<HealthConnectData>? healthData,
    List<HealthConnectWorkoutData>? workoutData,
  }) async {
    try {
      final dataToSync = healthData ?? await getHealthData();
      final workoutToSync = workoutData ?? await getWorkoutData();

      final payloads = <Map<String, dynamic>>[];

      for (final data in dataToSync) {
        final model = HealthConnectDataModel.fromEntity(data);
        payloads.add(model.toWatchLogPayload());
      }

      for (final workout in workoutToSync) {
        final model = HealthConnectWorkoutDataModel.fromEntity(workout);
        payloads.add(model.toWatchLogPayload());
      }

      if (payloads.isEmpty) return true;

      final response = await _watchLogDataSource.createManyWatchLog(payloads);

      if (response.success) {
        await saveLastSyncTimestamp(DateTime.now());
        _logger.i('Health data synced successfully to backend');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error syncing health data to backend: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    try {
      final timestamp = await _sharedPreferencesService.get<String>(
        'last_healthkit_sync_timestamp',
      );
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      _logger.e('Error getting last sync timestamp: $e');
      return null;
    }
  }

  @override
  Future<void> saveLastSyncTimestamp(DateTime timestamp) async {
    try {
      await _sharedPreferencesService.create(
        'last_healthkit_sync_timestamp',
        timestamp.toIso8601String(),
      );
    } catch (e) {
      _logger.e('Error saving last sync timestamp: $e');
    }
  }

  @override
  Stream<List<HealthConnectData>> get healthDataStream =>
      _healthDataController.stream;

  @override
  Stream<List<HealthConnectWorkoutData>> get workoutDataStream =>
      _workoutDataController.stream;

  void dispose() {
    _healthDataController.close();
    _workoutDataController.close();
  }
}
