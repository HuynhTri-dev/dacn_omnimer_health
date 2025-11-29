part of 'health_connect_bloc.dart';

abstract class HealthConnectState extends Equatable {
  const HealthConnectState();

  @override
  List<Object?> get props => [];
}

class HealthConnectInitial extends HealthConnectState {}

class HealthConnectLoading extends HealthConnectState {}

class HealthConnectAvailable extends HealthConnectState {
  final bool isInstalled;
  final bool hasPermissions;

  const HealthConnectAvailable({
    required this.isInstalled,
    required this.hasPermissions,
  });

  @override
  List<Object?> get props => [isInstalled, hasPermissions];
}

class HealthConnectUnavailable extends HealthConnectState {
  final String message;

  const HealthConnectUnavailable(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthConnectPermissionsGranted extends HealthConnectState {}

class HealthConnectPermissionsDenied extends HealthConnectState {
  final String message;

  const HealthConnectPermissionsDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthConnectError extends HealthConnectState {
  final String message;

  const HealthConnectError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthDataLoaded extends HealthConnectState {
  final HealthConnectData? todayData;
  final List<HealthConnectData> historicalData;
  final List<HealthConnectWorkoutData> workoutData;

  const HealthDataLoaded({
    this.todayData,
    this.historicalData = const [],
    this.workoutData = const [],
  });

  @override
  List<Object?> get props => [todayData, historicalData, workoutData];

  HealthDataLoaded copyWith({
    HealthConnectData? todayData,
    List<HealthConnectData>? historicalData,
    List<HealthConnectWorkoutData>? workoutData,
  }) {
    return HealthDataLoaded(
      todayData: todayData ?? this.todayData,
      historicalData: historicalData ?? this.historicalData,
      workoutData: workoutData ?? this.workoutData,
    );
  }
}

class HealthDataError extends HealthConnectState {
  final String message;

  const HealthDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthDataSyncSuccess extends HealthConnectState {
  final DateTime syncedAt;

  const HealthDataSyncSuccess(this.syncedAt);

  @override
  List<Object?> get props => [syncedAt];
}

class HealthDataSyncError extends HealthConnectState {
  final String message;

  const HealthDataSyncError(this.message);

  @override
  List<Object?> get props => [message];
}

class WorkoutSessionStarted extends HealthConnectState {
  final String workoutId;
  final String workoutType;
  final DateTime startedAt;

  const WorkoutSessionStarted({
    required this.workoutId,
    required this.workoutType,
    required this.startedAt,
  });

  @override
  List<Object?> get props => [workoutId, workoutType, startedAt];
}

class WorkoutSessionStopped extends HealthConnectState {
  final String workoutId;
  final Duration duration;

  const WorkoutSessionStopped({
    required this.workoutId,
    required this.duration,
  });

  @override
  List<Object?> get props => [workoutId, duration];
}

class HealthConnectSyncing extends HealthConnectState {
  final bool isSyncing;

  const HealthConnectSyncing({required this.isSyncing});

  @override
  List<Object?> get props => [isSyncing];
}
