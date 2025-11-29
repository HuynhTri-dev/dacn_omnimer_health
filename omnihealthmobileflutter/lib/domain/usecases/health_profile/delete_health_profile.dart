import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import '../base_usecase.dart';

class DeleteHealthProfileUseCase implements UseCase<ApiResponse<bool>, String> {
  final HealthProfileRepository repository;

  DeleteHealthProfileUseCase(this.repository);

  @override
  Future<ApiResponse<bool>> call(String params) async {
    return await repository.deleteHealthProfile(params);
  }
}
