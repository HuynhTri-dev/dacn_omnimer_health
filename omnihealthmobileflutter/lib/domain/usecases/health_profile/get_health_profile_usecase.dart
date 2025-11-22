import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile_entity.dart';

class GetHealthProfileUseCase {
  final HealthProfileRepository repository;

  GetHealthProfileUseCase(this.repository);

  Future<HealthProfileEntity> call() async {
    return await repository.getHealthProfile();
  }
}