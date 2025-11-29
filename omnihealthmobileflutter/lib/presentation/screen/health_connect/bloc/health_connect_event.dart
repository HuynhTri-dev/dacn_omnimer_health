part of 'health_connect_bloc.dart';

abstract class HealthConnectEvent extends Equatable {
  const HealthConnectEvent();

  @override
  List<Object?> get props => [];
}

class CheckHealthConnectAvailability extends HealthConnectEvent {}

class RequestHealthPermissions extends HealthConnectEvent {}

class GetTodayHealthData extends HealthConnectEvent {}

class GetHealthDataRange extends HealthConnectEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<HealthDataType>? types;

  const GetHealthDataRange({this.startDate, this.endDate, this.types});

  @override
  List<Object?> get props => [startDate, endDate, types];
}

class StartWorkoutSession extends HealthConnectEvent {
  final String workoutType;
  final Map<String, dynamic>? metadata;

  const StartWorkoutSession({required this.workoutType, this.metadata});

  @override
  List<Object?> get props => [workoutType, metadata];
}

class StopWorkoutSession extends HealthConnectEvent {
  final String workoutId;

  const StopWorkoutSession(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class SyncHealthDataToBackend extends HealthConnectEvent {
  final List<HealthConnectData>? healthData;
  final List<HealthConnectWorkoutData>? workoutData;

  const SyncHealthDataToBackend({this.healthData, this.workoutData});

  @override
  List<Object?> get props => [healthData, workoutData];
}

class GetWorkoutData extends HealthConnectEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetWorkoutData({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class StartHealthDataSync extends HealthConnectEvent {}

class StopHealthDataSync extends HealthConnectEvent {}
