import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/check_health_connect_availability.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/get_health_data_range.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/get_today_health_data.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/request_health_permissions.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/start_workout_session.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/stop_workout_session.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/sync_health_data_to_backend.dart';
import '../../../../../domain/entities/health_connect_entity.dart';
import '../../../../../domain/abstracts/health_connect_repository.dart';

part 'health_connect_event.dart';
part 'health_connect_state.dart';

class HealthConnectBloc extends Bloc<HealthConnectEvent, HealthConnectState> {
  final HealthConnectRepository _repository;
  final CheckHealthConnectAvailabilityUseCase _checkAvailability;
  final RequestHealthPermissionsUseCase _requestPermissions;
  final GetTodayHealthDataUseCase _getTodayHealthData;
  final GetHealthDataRangeUseCase _getHealthDataRange;
  final SyncHealthDataToBackendUseCase _syncDataToBackend;
  final StartWorkoutSessionUseCase _startWorkoutSession;
  final StopWorkoutSessionUseCase _stopWorkoutSession;

  StreamSubscription<List<HealthConnectData>>? _healthDataSubscription;
  StreamSubscription<List<HealthConnectWorkoutData>>? _workoutDataSubscription;

  HealthConnectBloc({
    required HealthConnectRepository repository,
    required CheckHealthConnectAvailabilityUseCase checkAvailability,
    required RequestHealthPermissionsUseCase requestPermissions,
    required GetTodayHealthDataUseCase getTodayHealthData,
    required GetHealthDataRangeUseCase getHealthDataRange,
    required SyncHealthDataToBackendUseCase syncDataToBackend,
    required StartWorkoutSessionUseCase startWorkoutSession,
    required StopWorkoutSessionUseCase stopWorkoutSession,
  }) : _repository = repository,
       _checkAvailability = checkAvailability,
       _requestPermissions = requestPermissions,
       _getTodayHealthData = getTodayHealthData,
       _getHealthDataRange = getHealthDataRange,
       _syncDataToBackend = syncDataToBackend,
       _startWorkoutSession = startWorkoutSession,
       _stopWorkoutSession = stopWorkoutSession,
       super(HealthConnectInitial()) {
    on<CheckHealthConnectAvailability>(_onCheckAvailability);
    on<RequestHealthPermissions>(_onRequestPermissions);
    on<GetTodayHealthData>(_onGetTodayHealthData);
    on<GetHealthDataRange>(_onGetHealthDataRange);
    on<StartWorkoutSession>(_onStartWorkoutSession);
    on<StopWorkoutSession>(_onStopWorkoutSession);
    on<SyncHealthDataToBackend>(_onSyncHealthDataToBackend);
    on<GetWorkoutData>(_onGetWorkoutData);
    on<StartHealthDataSync>(_onStartHealthDataSync);
    on<StopHealthDataSync>(_onStopHealthDataSync);
  }

  Future<void> _onCheckAvailability(
    CheckHealthConnectAvailability event,
    Emitter<HealthConnectState> emit,
  ) async {
    emit(HealthConnectLoading());
    try {
      final isAvailable = await _checkAvailability(NoParams());
      final isInstalled = await _repository.isHealthConnectInstalled();
      final hasPermissions = await _repository.hasPermissions();

      if (isAvailable) {
        emit(
          HealthConnectAvailable(
            isInstalled: isInstalled,
            hasPermissions: hasPermissions,
          ),
        );
      } else {
        emit(
          const HealthConnectUnavailable(
            'Health Connect is not available on this device',
          ),
        );
      }
    } catch (e) {
      emit(
        HealthConnectError('Failed to check Health Connect availability: $e'),
      );
    }
  }

  Future<void> _onRequestPermissions(
    RequestHealthPermissions event,
    Emitter<HealthConnectState> emit,
  ) async {
    emit(HealthConnectLoading());
    try {
      final granted = await _requestPermissions(NoParams());
      if (granted) {
        emit(HealthConnectPermissionsGranted());
      } else {
        emit(
          const HealthConnectPermissionsDenied(
            'Health Connect permissions were denied',
          ),
        );
      }
    } catch (e) {
      emit(
        HealthConnectError('Failed to request Health Connect permissions: $e'),
      );
    }
  }

  Future<void> _onGetTodayHealthData(
    GetTodayHealthData event,
    Emitter<HealthConnectState> emit,
  ) async {
    emit(HealthConnectLoading());
    try {
      final currentState = state;
      HealthDataLoaded? currentLoadedState;

      if (currentState is HealthDataLoaded) {
        currentLoadedState = currentState;
      }

      final todayData = await _getTodayHealthData(NoParams());
      emit(
        HealthDataLoaded(
          todayData: todayData,
          historicalData: currentLoadedState?.historicalData ?? [],
          workoutData: currentLoadedState?.workoutData ?? [],
        ),
      );
    } catch (e) {
      emit(HealthDataError('Failed to get today health data: $e'));
    }
  }

  Future<void> _onGetHealthDataRange(
    GetHealthDataRange event,
    Emitter<HealthConnectState> emit,
  ) async {
    emit(HealthConnectLoading());
    try {
      final historicalData = await _getHealthDataRange(
        GetHealthDataRangeParams(
          startDate: event.startDate,
          endDate: event.endDate,
          types: event.types,
        ),
      );

      final currentState = state;
      HealthDataLoaded? currentLoadedState;

      if (currentState is HealthDataLoaded) {
        currentLoadedState = currentState;
      }

      emit(
        HealthDataLoaded(
          todayData: currentLoadedState?.todayData,
          historicalData: historicalData,
          workoutData: currentLoadedState?.workoutData ?? [],
        ),
      );
    } catch (e) {
      emit(HealthDataError('Failed to get health data range: $e'));
    }
  }

  Future<void> _onStartWorkoutSession(
    StartWorkoutSession event,
    Emitter<HealthConnectState> emit,
  ) async {
    try {
      final workoutId = await _startWorkoutSession(
        StartWorkoutSessionParams(
          workoutType: event.workoutType,
          metadata: event.metadata,
        ),
      );

      emit(
        WorkoutSessionStarted(
          workoutId: workoutId,
          workoutType: event.workoutType,
          startedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(HealthDataError('Failed to start workout session: $e'));
    }
  }

  Future<void> _onStopWorkoutSession(
    StopWorkoutSession event,
    Emitter<HealthConnectState> emit,
  ) async {
    try {
      await _stopWorkoutSession(StopWorkoutSessionParams(event.workoutId));

      emit(
        WorkoutSessionStopped(
          workoutId: event.workoutId,
          duration: Duration.zero,
        ),
      );
    } catch (e) {
      emit(HealthDataError('Failed to stop workout session: $e'));
    }
  }

  Future<void> _onSyncHealthDataToBackend(
    SyncHealthDataToBackend event,
    Emitter<HealthConnectState> emit,
  ) async {
    emit(const HealthConnectSyncing(isSyncing: true));
    try {
      final success = await _syncDataToBackend(
        SyncHealthDataToBackendParams(
          healthData: event.healthData,
          workoutData: event.workoutData,
        ),
      );

      if (success) {
        emit(HealthDataSyncSuccess(DateTime.now()));
      } else {
        emit(const HealthDataSyncError('Failed to sync data to backend'));
      }
    } catch (e) {
      emit(HealthDataError('Failed to sync health data: $e'));
    }
  }

  Future<void> _onGetWorkoutData(
    GetWorkoutData event,
    Emitter<HealthConnectState> emit,
  ) async {
    try {
      final workoutData = await _repository.getWorkoutData(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final currentState = state;
      HealthDataLoaded? currentLoadedState;

      if (currentState is HealthDataLoaded) {
        currentLoadedState = currentState;
      }

      emit(
        HealthDataLoaded(
          todayData: currentLoadedState?.todayData,
          historicalData: currentLoadedState?.historicalData ?? [],
          workoutData: workoutData,
        ),
      );
    } catch (e) {
      emit(HealthDataError('Failed to get workout data: $e'));
    }
  }

  Future<void> _onStartHealthDataSync(
    StartHealthDataSync event,
    Emitter<HealthConnectState> emit,
  ) async {
    await _healthDataSubscription?.cancel();
    await _workoutDataSubscription?.cancel();

    _healthDataSubscription = _repository.healthDataStream.listen(
      (data) {
        final currentState = state;
        if (currentState is HealthDataLoaded) {
          add(GetHealthDataRange());
        }
      },
      onError: (error) {
        emit(HealthDataError('Health data stream error: $error'));
      },
    );

    _workoutDataSubscription = _repository.workoutDataStream.listen(
      (data) {
        add(GetWorkoutData());
      },
      onError: (error) {
        emit(HealthDataError('Workout data stream error: $error'));
      },
    );
  }

  Future<void> _onStopHealthDataSync(
    StopHealthDataSync event,
    Emitter<HealthConnectState> emit,
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
