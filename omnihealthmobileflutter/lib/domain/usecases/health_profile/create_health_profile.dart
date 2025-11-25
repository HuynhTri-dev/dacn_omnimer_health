import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class CreateHealthProfileUseCase {
  final HealthProfileRepository _repository;

  CreateHealthProfileUseCase(this._repository);

  Future<HealthProfile> call(HealthProfile profile) async {
    return await _repository.createHealthProfile(profile);
  }
}