import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/body_part_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến BodyPart
abstract class BodyPartDataSource {
  /// Lấy danh sách tất cả body parts
  Future<ApiResponse<List<BodyPartModel>>> getAllBodyParts();
}

class BodyPartDataSourceImpl implements BodyPartDataSource {
  final ApiClient apiClient;

  BodyPartDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<BodyPartModel>>> getAllBodyParts() async {
    try {
      final response = await apiClient.get<List<BodyPartModel>>(
        Endpoints.getBodyParts,
        requiresAuth: false,
        parser: (json) {
          // Parse list từ JSON
          if (json is List) {
            return json
                .map((e) => BodyPartModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <BodyPartModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<BodyPartModel>>.error(
        "Lấy danh sách body parts thất bại: ${e.toString()}",
      );
    }
  }
}
