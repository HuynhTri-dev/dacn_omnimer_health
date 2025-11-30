part of 'healthkit_connect_bloc.dart';

abstract class HealthKitConnectEvent extends Equatable {
  const HealthKitConnectEvent();

  @override
  List<Object?> get props => [];
}

class CheckHealthKitAvailability extends HealthKitConnectEvent {}

class RequestHealthKitPermissions extends HealthKitConnectEvent {}

class GetTodayHealthKitData extends HealthKitConnectEvent {}

class GetHealthKitDataRange extends HealthKitConnectEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<HealthDataType>? types;

  const GetHealthKitDataRange({this.startDate, this.endDate, this.types});

  @override
  List<Object?> get props => [startDate, endDate, types];
}

class StartHealthKitWorkoutSession extends HealthKitConnectEvent {
  final String workoutType;
  final Map<String, dynamic>? metadata;

  const StartHealthKitWorkoutSession({
    required this.workoutType,
    this.metadata,
  });

  @override
  List<Object?> get props => [workoutType, metadata];
}

class StopHealthKitWorkoutSession extends HealthKitConnectEvent {
  final String workoutId;

  const StopHealthKitWorkoutSession(this.workoutId);

  @override
  List<Object?> get props => [workoutId];
}

class SyncHealthKitDataToBackend extends HealthKitConnectEvent {
  final List<HealthConnectData>? healthData;
  final List<HealthConnectWorkoutData>? workoutData;

  const SyncHealthKitDataToBackend({this.healthData, this.workoutData});

  @override
  List<Object?> get props => [healthData, workoutData];
}

class GetHealthKitWorkoutData extends HealthKitConnectEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetHealthKitWorkoutData({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class StartHealthKitDataSync extends HealthKitConnectEvent {}

class StopHealthKitDataSync extends HealthKitConnectEvent {}
