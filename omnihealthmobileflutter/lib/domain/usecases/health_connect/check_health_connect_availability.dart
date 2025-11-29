import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import '../base_usecase.dart';

class CheckHealthConnectAvailabilityUseCase implements UseCase<bool, NoParams> {
  final HealthConnectRepository _repository;

  CheckHealthConnectAvailabilityUseCase(this._repository);

  @override
  Future<bool> call(NoParams params) async {
    return await _repository.isHealthConnectAvailable();
  }
}
