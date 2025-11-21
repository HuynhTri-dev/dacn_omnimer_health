import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/muscle/muscle_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến Muscle
abstract class MuscleDataSource {
  /// Lấy danh sách tất cả roles (để hiển thị select box)
  Future<ApiResponse<MuscleModel>> getMuscleById(String id);

  /// Lấy danh sách tất cả roles (để hiển thị select box)
  Future<ApiResponse<List<MuscleModel>>> getAllMuscles();
}

class MuscleDataSourceImpl implements MuscleDataSource {
  final ApiClient apiClient;

  MuscleDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<MuscleModel>> getMuscleById(String id) async {
    try {
      final response = await apiClient.get<MuscleModel>(
        Endpoints.getMuscleById(id),
        requiresAuth: false,
        parser: (json) => MuscleModel.fromJson(json),
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<MuscleModel>.error(
        "Get Muscle Error: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<List<MuscleModel>>> getAllMuscles() async {
    try {
      final response = await apiClient.get<List<MuscleModel>>(
        Endpoints.getMuscles,
        requiresAuth: false,
        parser: (json) {
          // Parse list từ JSON
          if (json is List) {
            return json
                .map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <MuscleModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<MuscleModel>>.error(
        "Get All Muscles Error: ${e.toString()}",
      );
    }
  }
}
