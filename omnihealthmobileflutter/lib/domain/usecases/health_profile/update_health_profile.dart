import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import '../base_usecase.dart';

class UpdateHealthProfileParams {
  final String id;
  final HealthProfile profile;

  UpdateHealthProfileParams({required this.id, required this.profile});
}

class UpdateHealthProfileUseCase
    implements UseCase<ApiResponse<HealthProfile>, UpdateHealthProfileParams> {
  final HealthProfileRepository repository;

  UpdateHealthProfileUseCase(this.repository);

  @override
  Future<ApiResponse<HealthProfile>> call(
    UpdateHealthProfileParams params,
  ) async {
    return await repository.updateHealthProfile(params.id, params.profile);
  }
}
