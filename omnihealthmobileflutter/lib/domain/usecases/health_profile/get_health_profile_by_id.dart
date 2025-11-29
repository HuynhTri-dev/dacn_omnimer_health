import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import '../base_usecase.dart';

class GetHealthProfileByIdUseCase
    implements UseCase<ApiResponse<HealthProfile>, String> {
  final HealthProfileRepository repository;

  GetHealthProfileByIdUseCase(this.repository);

  @override
  Future<ApiResponse<HealthProfile>> call(String params) async {
    return await repository.getHealthProfileById(params);
  }
}
