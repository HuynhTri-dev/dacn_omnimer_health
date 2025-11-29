import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import '../base_usecase.dart';

class GetHealthProfilesByUserIdUseCase
    implements UseCase<ApiResponse<List<HealthProfile>>, String> {
  final HealthProfileRepository repository;

  GetHealthProfilesByUserIdUseCase(this.repository);

  @override
  Future<ApiResponse<List<HealthProfile>>> call(String params) async {
    return await repository.getHealthProfilesByUserId(params);
  }
}
