import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import '../base_usecase.dart';

class StopWorkoutSessionUseCase
    implements UseCase<void, StopWorkoutSessionParams> {
  final HealthConnectRepository _repository;

  StopWorkoutSessionUseCase(this._repository);

  @override
  Future<void> call(StopWorkoutSessionParams params) async {
    await _repository.stopWorkoutSession(params.workoutId);
  }
}

class StopWorkoutSessionParams {
  final String workoutId;

  StopWorkoutSessionParams(this.workoutId);
}
