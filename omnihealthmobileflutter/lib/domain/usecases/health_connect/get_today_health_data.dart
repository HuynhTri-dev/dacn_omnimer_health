import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_connect_entity.dart';
import '../base_usecase.dart';

class GetTodayHealthDataUseCase
    implements UseCase<HealthConnectData?, NoParams> {
  final HealthConnectRepository _repository;

  GetTodayHealthDataUseCase(this._repository);

  @override
  Future<HealthConnectData?> call(NoParams params) async {
    return await _repository.getTodayHealthData();
  }
}
