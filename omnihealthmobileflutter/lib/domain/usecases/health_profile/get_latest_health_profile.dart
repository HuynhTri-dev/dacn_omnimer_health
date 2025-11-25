import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class GetLatestHealthProfileUseCase {
  final HealthProfileRepository _repository;

  GetLatestHealthProfileUseCase(this._repository);

  Future<HealthProfile> call() async {
    return await _repository.getLatestHealthProfile();
  }
}