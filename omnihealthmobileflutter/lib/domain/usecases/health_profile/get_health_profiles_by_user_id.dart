import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class GetHealthProfilesByUserIdUseCase {
  final HealthProfileRepository _repository;

  GetHealthProfilesByUserIdUseCase(this._repository);

  Future<List<HealthProfile>> call(String userId) async {
    return await _repository.getHealthProfilesByUserId(userId);
  }
}