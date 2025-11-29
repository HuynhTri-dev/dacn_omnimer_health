part of 'healthkit_connect_bloc.dart';

abstract class HealthKitConnectState extends Equatable {
  const HealthKitConnectState();

  @override
  List<Object?> get props => [];
}

class HealthKitConnectInitial extends HealthKitConnectState {}

class HealthKitConnectLoading extends HealthKitConnectState {}

class HealthKitConnectAvailable extends HealthKitConnectState {
  final bool hasPermissions;

  const HealthKitConnectAvailable({required this.hasPermissions});

  @override
  List<Object?> get props => [hasPermissions];
}

class HealthKitConnectUnavailable extends HealthKitConnectState {
  final String message;

  const HealthKitConnectUnavailable(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthKitConnectPermissionsGranted extends HealthKitConnectState {}

class HealthKitConnectPermissionsDenied extends HealthKitConnectState {
  final String message;

  const HealthKitConnectPermissionsDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthKitConnectError extends HealthKitConnectState {
  final String message;

  const HealthKitConnectError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthKitDataLoaded extends HealthKitConnectState {
  final HealthConnectData? todayData;
  final List<HealthConnectData> historicalData;
  final List<HealthConnectWorkoutData> workoutData;

  const HealthKitDataLoaded({
    this.todayData,
    this.historicalData = const [],
    this.workoutData = const [],
  });

  @override
  List<Object?> get props => [todayData, historicalData, workoutData];

  HealthKitDataLoaded copyWith({
    HealthConnectData? todayData,
    List<HealthConnectData>? historicalData,
    List<HealthConnectWorkoutData>? workoutData,
  }) {
    return HealthKitDataLoaded(
      todayData: todayData ?? this.todayData,
      historicalData: historicalData ?? this.historicalData,
      workoutData: workoutData ?? this.workoutData,
    );
  }
}

class HealthKitDataError extends HealthKitConnectState {
  final String message;

  const HealthKitDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthKitDataSyncSuccess extends HealthKitConnectState {
  final DateTime syncedAt;

  const HealthKitDataSyncSuccess(this.syncedAt);

  @override
  List<Object?> get props => [syncedAt];
}

class HealthKitDataSyncError extends HealthKitConnectState {
  final String message;

  const HealthKitDataSyncError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthKitWorkoutSessionStarted extends HealthKitConnectState {
  final String workoutId;
  final String workoutType;
  final DateTime startedAt;

  const HealthKitWorkoutSessionStarted({
    required this.workoutId,
    required this.workoutType,
    required this.startedAt,
  });

  @override
  List<Object?> get props => [workoutId, workoutType, startedAt];
}

class HealthKitWorkoutSessionStopped extends HealthKitConnectState {
  final String workoutId;
  final Duration duration;

  const HealthKitWorkoutSessionStopped({
    required this.workoutId,
    required this.duration,
  });

  @override
  List<Object?> get props => [workoutId, duration];
}

class HealthKitConnectSyncing extends HealthKitConnectState {
  final bool isSyncing;

  const HealthKitConnectSyncing({required this.isSyncing});

  @override
  List<Object?> get props => [isSyncing];
}
