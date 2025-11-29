import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/health_connect_entity.dart';
import '../../../../../domain/abstracts/healthkit_connect_abs.dart';

part 'healthkit_connect_event.dart';
part 'healthkit_connect_state.dart';

class HealthKitConnectBloc
    extends Bloc<HealthKitConnectEvent, HealthKitConnectState> {
  final HealthKitConnectRepository _repository;

  StreamSubscription<List<HealthConnectData>>? _healthDataSubscription;
  StreamSubscription<List<HealthConnectWorkoutData>>? _workoutDataSubscription;

  HealthKitConnectBloc({required HealthKitConnectRepository repository})
    : _repository = repository,
      super(HealthKitConnectInitial()) {
    on<CheckHealthKitAvailability>(_onCheckAvailability);
    on<RequestHealthKitPermissions>(_onRequestPermissions);
    on<GetTodayHealthKitData>(_onGetTodayHealthData);
    on<GetHealthKitDataRange>(_onGetHealthDataRange);
    on<StartHealthKitWorkoutSession>(_onStartWorkoutSession);
    on<StopHealthKitWorkoutSession>(_onStopWorkoutSession);
    on<SyncHealthKitDataToBackend>(_onSyncHealthDataToBackend);
    on<GetHealthKitWorkoutData>(_onGetWorkoutData);
    on<StartHealthKitDataSync>(_onStartHealthDataSync);
    on<StopHealthKitDataSync>(_onStopHealthDataSync);
  }

  Future<void> _onCheckAvailability(
    CheckHealthKitAvailability event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    emit(HealthKitConnectLoading());
    try {
      final isAvailable = await _repository.isHealthKitAvailable();

      if (isAvailable) {
        final hasPermissions = await _repository.hasPermissions();
        emit(HealthKitConnectAvailable(hasPermissions: hasPermissions));
      } else {
        emit(
          const HealthKitConnectUnavailable(
            'HealthKit is not available on this device',
          ),
        );
      }
    } catch (e) {
      emit(HealthKitConnectError('Failed to check HealthKit availability: $e'));
    }
  }

  Future<void> _onRequestPermissions(
    RequestHealthKitPermissions event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    emit(HealthKitConnectLoading());
    try {
      final granted = await _repository.requestPermissions();
      if (granted) {
        emit(HealthKitConnectPermissionsGranted());
        // After granting permissions, check availability again to update state
        add(CheckHealthKitAvailability());
      } else {
        emit(
          const HealthKitConnectPermissionsDenied(
            'HealthKit permissions were denied',
          ),
        );
      }
    } catch (e) {
      emit(
        HealthKitConnectError('Failed to request HealthKit permissions: $e'),
      );
    }
  }

  Future<void> _onGetTodayHealthData(
    GetTodayHealthKitData event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    emit(HealthKitConnectLoading());
    try {
      final currentState = state;
      HealthKitDataLoaded? currentLoadedState;

      if (currentState is HealthKitDataLoaded) {
        currentLoadedState = currentState;
      }

      final todayData = await _repository.getTodayHealthData();
      emit(
        HealthKitDataLoaded(
          todayData: todayData,
          historicalData: currentLoadedState?.historicalData ?? [],
          workoutData: currentLoadedState?.workoutData ?? [],
        ),
      );
    } catch (e) {
      emit(HealthKitDataError('Failed to get today health data: $e'));
    }
  }

  Future<void> _onGetHealthDataRange(
    GetHealthKitDataRange event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    emit(HealthKitConnectLoading());
    try {
      final historicalData = await _repository.getHealthData(
        startDate: event.startDate,
        endDate: event.endDate,
        types: event.types,
      );

      final currentState = state;
      HealthKitDataLoaded? currentLoadedState;

      if (currentState is HealthKitDataLoaded) {
        currentLoadedState = currentState;
      }

      emit(
        HealthKitDataLoaded(
          todayData: currentLoadedState?.todayData,
          historicalData: historicalData,
          workoutData: currentLoadedState?.workoutData ?? [],
        ),
      );
    } catch (e) {
      emit(HealthKitDataError('Failed to get health data range: $e'));
    }
  }

  Future<void> _onStartWorkoutSession(
    StartHealthKitWorkoutSession event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    try {
      final workoutId = await _repository.startWorkoutSession(
        workoutType: event.workoutType,
        metadata: event.metadata,
      );

      emit(
        HealthKitWorkoutSessionStarted(
          workoutId: workoutId,
          workoutType: event.workoutType,
          startedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(HealthKitDataError('Failed to start workout session: $e'));
    }
  }

  Future<void> _onStopWorkoutSession(
    StopHealthKitWorkoutSession event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    try {
      await _repository.stopWorkoutSession(event.workoutId);

      emit(
        HealthKitWorkoutSessionStopped(
          workoutId: event.workoutId,
          duration:
              Duration.zero, // You might want to calculate actual duration
        ),
      );
    } catch (e) {
      emit(HealthKitDataError('Failed to stop workout session: $e'));
    }
  }

  Future<void> _onSyncHealthDataToBackend(
    SyncHealthKitDataToBackend event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    emit(const HealthKitConnectSyncing(isSyncing: true));
    try {
      final success = await _repository.syncHealthDataToBackend(
        healthData: event.healthData,
        workoutData: event.workoutData,
      );

      if (success) {
        emit(HealthKitDataSyncSuccess(DateTime.now()));
      } else {
        emit(const HealthKitDataSyncError('Failed to sync data to backend'));
      }
    } catch (e) {
      emit(HealthKitDataError('Failed to sync health data: $e'));
    }
  }

  Future<void> _onGetWorkoutData(
    GetHealthKitWorkoutData event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    try {
      final workoutData = await _repository.getWorkoutData(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final currentState = state;
      HealthKitDataLoaded? currentLoadedState;

      if (currentState is HealthKitDataLoaded) {
        currentLoadedState = currentState;
      }

      emit(
        HealthKitDataLoaded(
          todayData: currentLoadedState?.todayData,
          historicalData: currentLoadedState?.historicalData ?? [],
          workoutData: workoutData,
        ),
      );
    } catch (e) {
      emit(HealthKitDataError('Failed to get workout data: $e'));
    }
  }

  Future<void> _onStartHealthDataSync(
    StartHealthKitDataSync event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    await _healthDataSubscription?.cancel();
    await _workoutDataSubscription?.cancel();

    _healthDataSubscription = _repository.healthDataStream.listen(
      (data) {
        // When new data comes in, refresh the range or today's data
        // For now, let's just trigger a refresh of today's data
        add(GetTodayHealthKitData());
      },
      onError: (error) {
        emit(HealthKitDataError('Health data stream error: $error'));
      },
    );

    _workoutDataSubscription = _repository.workoutDataStream.listen(
      (data) {
        add(GetHealthKitWorkoutData());
      },
      onError: (error) {
        emit(HealthKitDataError('Workout data stream error: $error'));
      },
    );
  }

  Future<void> _onStopHealthDataSync(
    StopHealthKitDataSync event,
    Emitter<HealthKitConnectState> emit,
  ) async {
    await _healthDataSubscription?.cancel();
    await _workoutDataSubscription?.cancel();
    _healthDataSubscription = null;
    _workoutDataSubscription = null;
  }

  @override
  Future<void> close() {
    _healthDataSubscription?.cancel();
    _workoutDataSubscription?.cancel();
    return super.close();
  }
}
