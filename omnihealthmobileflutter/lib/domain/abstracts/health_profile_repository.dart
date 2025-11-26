import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

abstract class HealthProfileRepository {
  Future<ApiResponse<List<HealthProfile>>> getHealthProfiles();
  Future<ApiResponse<HealthProfile>> getHealthProfileById(String id);
  Future<ApiResponse<HealthProfile>> getLatestHealthProfile();
  Future<ApiResponse<HealthProfile>> getHealthProfileByDate(String date);
  Future<ApiResponse<List<HealthProfile>>> getHealthProfilesByUserId(
    String userId,
  );
  Future<ApiResponse<HealthProfile>> createHealthProfile(HealthProfile profile);
  Future<ApiResponse<HealthProfile>> updateHealthProfile(
    String id,
    HealthProfile profile,
  );
  Future<ApiResponse<bool>> deleteHealthProfile(String id);
}
