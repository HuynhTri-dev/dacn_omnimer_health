import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_connect_entity.dart';
import '../base_usecase.dart';

class GetHealthDataRangeUseCase
    implements UseCase<List<HealthConnectData>, GetHealthDataRangeParams> {
  final HealthConnectRepository _repository;

  GetHealthDataRangeUseCase(this._repository);

  @override
  Future<List<HealthConnectData>> call(GetHealthDataRangeParams params) async {
    return await _repository.getHealthData(
      startDate: params.startDate,
      endDate: params.endDate,
      types: params.types,
    );
  }
}

class GetHealthDataRangeParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<HealthDataType>? types;

  GetHealthDataRangeParams({this.startDate, this.endDate, this.types});
}
