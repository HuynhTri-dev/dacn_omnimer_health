import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class UpdateHealthProfileUseCase {
  final HealthProfileRepository _repository;

  UpdateHealthProfileUseCase(this._repository);

  Future<HealthProfile> call(String id, HealthProfile profile) async {
    return await _repository.updateHealthProfile(id, profile);
  }
}