import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/health_profile_remote_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/health_profile/health_profile_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class HealthProfileRepositoryImpl implements HealthProfileRepository {
  final HealthProfileRemoteDataSource remoteDataSource;

  HealthProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<List<HealthProfile>>> getHealthProfiles() async {
    try {
      final response = await remoteDataSource.getHealthProfiles();

      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <HealthProfile>[];

      return ApiResponse<List<HealthProfile>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<HealthProfile>>.error(
        "Không thể lấy danh sách hồ sơ sức khỏe: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfile>> getHealthProfileById(String id) async {
    try {
      final response = await remoteDataSource.getHealthProfileById(id);

      return ApiResponse<HealthProfile>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<HealthProfile>.error(
        "Không thể lấy hồ sơ sức khỏe: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfile>> getLatestHealthProfile() async {
    try {
      final response = await remoteDataSource.getLatestHealthProfile();

      return ApiResponse<HealthProfile>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<HealthProfile>.error(
        "Không thể lấy hồ sơ sức khỏe mới nhất: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfile>> getHealthProfileByDate(String date) async {
    try {
      final response = await remoteDataSource.getHealthProfileByDate(date);

      return ApiResponse<HealthProfile>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<HealthProfile>.error(
        "Không thể lấy hồ sơ sức khỏe theo ngày: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<List<HealthProfile>>> getHealthProfilesByUserId(
    String userId,
  ) async {
    try {
      final response = await remoteDataSource.getHealthProfilesByUserId(userId);

      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <HealthProfile>[];

      return ApiResponse<List<HealthProfile>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<HealthProfile>>.error(
        "Không thể lấy danh sách hồ sơ sức khỏe theo User ID: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfile>> createHealthProfile(
    HealthProfile profile,
  ) async {
    try {
      final model = HealthProfileModel.fromEntity(profile);
      final response = await remoteDataSource.createHealthProfile(model);

      return ApiResponse<HealthProfile>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<HealthProfile>.error(
        "Không thể tạo hồ sơ sức khỏe: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<HealthProfile>> updateHealthProfile(
    String id,
    HealthProfile profile,
  ) async {
    try {
      final model = HealthProfileModel.fromEntity(profile);
      final response = await remoteDataSource.updateHealthProfile(id, model);

      return ApiResponse<HealthProfile>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<HealthProfile>.error(
        "Không thể cập nhật hồ sơ sức khỏe: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<bool>> deleteHealthProfile(String id) async {
    try {
      final response = await remoteDataSource.deleteHealthProfile(id);

      return ApiResponse<bool>(
        success: response.success,
        message: response.message,
        data: response.data,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<bool>.error(
        "Không thể xóa hồ sơ sức khỏe: ${e.toString()}",
        error: e,
      );
    }
  }
}
