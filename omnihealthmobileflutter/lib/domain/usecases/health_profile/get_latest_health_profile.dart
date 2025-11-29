import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import '../base_usecase.dart';

class GetLatestHealthProfileUseCase
    implements UseCase<ApiResponse<HealthProfile>, NoParams> {
  final HealthProfileRepository repository;

  GetLatestHealthProfileUseCase(this.repository);

  @override
  Future<ApiResponse<HealthProfile>> call(NoParams params) async {
    return await repository.getLatestHealthProfile();
  }
}
