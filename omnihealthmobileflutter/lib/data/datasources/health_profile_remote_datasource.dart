import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/health_profile/health_profile_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

abstract class HealthProfileRemoteDataSource {
  Future<ApiResponse<List<HealthProfileModel>>> getHealthProfiles();
  Future<ApiResponse<HealthProfileModel>> getHealthProfileById(String id);
  Future<ApiResponse<HealthProfileModel>> getLatestHealthProfile();
  Future<ApiResponse<HealthProfileModel>> getHealthProfileByDate(String date);
  Future<ApiResponse<List<HealthProfileModel>>> getHealthProfilesByUserId(
    String userId,
  );
  Future<ApiResponse<HealthProfileModel>> createHealthProfile(
    HealthProfileModel profile,
  );
  Future<ApiResponse<HealthProfileModel>> updateHealthProfile(
    String id,
    HealthProfileModel profile,
  );
  Future<ApiResponse<bool>> deleteHealthProfile(String id);
}

class HealthProfileRemoteDataSourceImpl
    implements HealthProfileRemoteDataSource {
  final ApiClient apiClient;

  HealthProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<HealthProfileModel>>> getHealthProfiles() async {
    try {
      final response = await apiClient.get<List<HealthProfileModel>>(
        Endpoints.getHealthProfiles,
        parser: (json) {
          if (json is List) {
            return json
                .map(
                  (e) => HealthProfileModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          return <HealthProfileModel>[];
        },
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Lấy danh sách hồ sơ sức khỏe thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfileModel>> getHealthProfileById(
    String id,
  ) async {
    try {
      final response = await apiClient.get<HealthProfileModel>(
        Endpoints.getHealthProfileById(id),
        parser: (json) =>
            HealthProfileModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error("Lấy hồ sơ sức khỏe thất bại: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<HealthProfileModel>> getLatestHealthProfile() async {
    try {
      final response = await apiClient.get<HealthProfileModel>(
        Endpoints.getLatestHealthProfile,
        parser: (json) =>
            HealthProfileModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Lấy hồ sơ sức khỏe mới nhất thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfileModel>> getHealthProfileByDate(
    String date,
  ) async {
    try {
      final response = await apiClient.get<HealthProfileModel>(
        Endpoints.getHealthProfileByDate(date),
        parser: (json) =>
            HealthProfileModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Lấy hồ sơ sức khỏe theo ngày thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<List<HealthProfileModel>>> getHealthProfilesByUserId(
    String userId,
  ) async {
    try {
      final response = await apiClient.get<List<HealthProfileModel>>(
        Endpoints.getHealthProfilesByUserId(userId),
        parser: (json) {
          if (json is List) {
            return json
                .map(
                  (e) => HealthProfileModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          return <HealthProfileModel>[];
        },
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Lấy danh sách hồ sơ sức khỏe theo User ID thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfileModel>> createHealthProfile(
    HealthProfileModel profile,
  ) async {
    try {
      final response = await apiClient.post<HealthProfileModel>(
        Endpoints.createHealthProfile,
        data: profile.toJson(),
        parser: (json) =>
            HealthProfileModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error("Tạo hồ sơ sức khỏe thất bại: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<HealthProfileModel>> updateHealthProfile(
    String id,
    HealthProfileModel profile,
  ) async {
    try {
      final response = await apiClient.put<HealthProfileModel>(
        Endpoints.updateHealthProfile(id),
        data: profile.toJson(),
        parser: (json) =>
            HealthProfileModel.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error(
        "Cập nhật hồ sơ sức khỏe thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<bool>> deleteHealthProfile(String id) async {
    try {
      final response = await apiClient.delete<bool>(
        Endpoints.deleteHealthProfile(id),
        parser: (json) => true,
      );
      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse.error("Xóa hồ sơ sức khỏe thất bại: ${e.toString()}");
    }
  }
}
