import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import '../base_usecase.dart';

class GetHealthProfilesUseCase
    implements UseCase<ApiResponse<List<HealthProfile>>, NoParams> {
  final HealthProfileRepository repository;

  GetHealthProfilesUseCase(this.repository);

  @override
  Future<ApiResponse<List<HealthProfile>>> call(NoParams params) async {
    return await repository.getHealthProfiles();
  }
}
