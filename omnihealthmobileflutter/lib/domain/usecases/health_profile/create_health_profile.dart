import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import '../base_usecase.dart';

class CreateHealthProfileUseCase
    implements UseCase<ApiResponse<HealthProfile>, HealthProfile> {
  final HealthProfileRepository repository;

  CreateHealthProfileUseCase(this.repository);

  @override
  Future<ApiResponse<HealthProfile>> call(HealthProfile params) async {
    return await repository.createHealthProfile(params);
  }
}
