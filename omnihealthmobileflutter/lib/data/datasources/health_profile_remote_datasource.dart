import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/health_profile/health_profile_model.dart';


abstract class HealthProfileRemoteDataSource {
  Future<List<HealthProfileModel>> getHealthProfiles();
  Future<HealthProfileModel> getHealthProfileById(String id);
  Future<HealthProfileModel> getLatestHealthProfile();
  Future<List<HealthProfileModel>> getHealthProfilesByUserId(String userId);
  Future<HealthProfileModel> createHealthProfile(HealthProfileModel profile);
  Future<HealthProfileModel> updateHealthProfile(String id, HealthProfileModel profile);
  Future<void> deleteHealthProfile(String id);
}

class HealthProfileRemoteDataSourceImpl implements HealthProfileRemoteDataSource {
  final ApiClient apiClient;

  HealthProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<HealthProfileModel>> getHealthProfiles() async {
    final response = await apiClient.get(Endpoints.getHealthProfiles);
    return (response.data['data'] as List)
        .map((json) => HealthProfileModel.fromJson(json))
        .toList();
  }

  @override
  Future<HealthProfileModel> getHealthProfileById(String id) async {
    final response = await apiClient.get(Endpoints.getHealthProfileById(id));
    return HealthProfileModel.fromJson(response.data['data']);
  }

  @override
  Future<HealthProfileModel> getLatestHealthProfile() async {
    final response = await apiClient.get(Endpoints.getLatestHealthProfile);
    return HealthProfileModel.fromJson(response.data['data']);
  }

  @override
  Future<List<HealthProfileModel>> getHealthProfilesByUserId(String userId) async {
    final response = await apiClient.get(Endpoints.getHealthProfilesByUserId(userId));
    return (response.data['data'] as List)
        .map((json) => HealthProfileModel.fromJson(json))
        .toList();
  }

  @override
  Future<HealthProfileModel> createHealthProfile(HealthProfileModel profile) async {
    final response = await apiClient.post(
      Endpoints.createHealthProfile,
      data: profile.toJson(),
    );
    return HealthProfileModel.fromJson(response.data['data']);
  }

  @override
  Future<HealthProfileModel> updateHealthProfile(String id, HealthProfileModel profile) async {
    final response = await apiClient.put(
      Endpoints.updateHealthProfile(id),
      data: profile.toJson(),
    );
    return HealthProfileModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteHealthProfile(String id) async {
    await apiClient.delete(Endpoints.deleteHealthProfile(id));
  }
}