import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile_entity.dart';

class UpdateHealthProfileUseCase {
  final HealthProfileRepository repository;

  UpdateHealthProfileUseCase(this.repository);

  Future<void> call(HealthProfileEntity profile) async {
    return await repository.updateHealthProfile(profile);
  }
}