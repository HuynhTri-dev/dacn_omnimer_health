import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

abstract class HealthProfileRepository {
  Future<List<HealthProfile>> getHealthProfiles();
  Future<HealthProfile> getHealthProfileById(String id);
  Future<HealthProfile> getLatestHealthProfile();
  Future<List<HealthProfile>> getHealthProfilesByUserId(String userId);
  Future<HealthProfile> createHealthProfile(HealthProfile profile);
  Future<HealthProfile> updateHealthProfile(String id, HealthProfile profile);
  Future<void> deleteHealthProfile(String id);
}