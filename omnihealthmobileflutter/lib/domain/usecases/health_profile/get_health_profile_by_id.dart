import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class GetHealthProfileByIdUseCase {
  final HealthProfileRepository _repository;

  GetHealthProfileByIdUseCase(this._repository);

  Future<HealthProfile> call(String id) async {
    return await _repository.getHealthProfileById(id);
  }
}