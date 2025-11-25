import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class GetHealthProfilesUseCase {
  final HealthProfileRepository _repository;

  GetHealthProfilesUseCase(this._repository);

  Future<List<HealthProfile>> call() async {
    return await _repository.getHealthProfiles();
  }
}
