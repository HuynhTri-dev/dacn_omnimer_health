import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import '../base_usecase.dart';

class RequestHealthPermissionsUseCase implements UseCase<bool, NoParams> {
  final HealthConnectRepository _repository;

  RequestHealthPermissionsUseCase(this._repository);

  @override
  Future<bool> call(NoParams params) async {
    final isInstalled = await _repository.isHealthConnectInstalled();
    if (!isInstalled) {
      await _repository.installHealthConnect();
    }

    return await _repository.requestPermissions();
  }
}
