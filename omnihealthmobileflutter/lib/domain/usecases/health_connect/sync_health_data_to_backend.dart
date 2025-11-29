import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_connect_entity.dart';
import '../base_usecase.dart';

class SyncHealthDataToBackendUseCase
    implements UseCase<bool, SyncHealthDataToBackendParams> {
  final HealthConnectRepository _repository;

  SyncHealthDataToBackendUseCase(this._repository);

  @override
  Future<bool> call(SyncHealthDataToBackendParams params) async {
    return await _repository.syncHealthDataToBackend(
      healthData: params.healthData,
      workoutData: params.workoutData,
    );
  }
}

class SyncHealthDataToBackendParams {
  final List<HealthConnectData>? healthData;
  final List<HealthConnectWorkoutData>? workoutData;

  SyncHealthDataToBackendParams({this.healthData, this.workoutData});
}
