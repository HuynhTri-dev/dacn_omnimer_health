import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import '../base_usecase.dart';

class StartWorkoutSessionUseCase
    implements UseCase<String, StartWorkoutSessionParams> {
  final HealthConnectRepository _repository;

  StartWorkoutSessionUseCase(this._repository);

  @override
  Future<String> call(StartWorkoutSessionParams params) async {
    return await _repository.startWorkoutSession(
      workoutType: params.workoutType,
      metadata: params.metadata,
    );
  }
}

class StartWorkoutSessionParams {
  final String workoutType;
  final Map<String, dynamic>? metadata;

  StartWorkoutSessionParams({required this.workoutType, this.metadata});
}
