import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetHealthProfileByDateUseCase
    implements UseCase<ApiResponse<HealthProfile>, String> {
  final HealthProfileRepository _repository;

  GetHealthProfileByDateUseCase(this._repository);

  @override
  Future<ApiResponse<HealthProfile>> call(String date) {
    return _repository.getHealthProfileByDate(date);
  }
}
