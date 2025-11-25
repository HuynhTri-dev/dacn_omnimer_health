import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';

class DeleteHealthProfileUseCase {
  final HealthProfileRepository _repository;

  DeleteHealthProfileUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteHealthProfile(id);
  }
}