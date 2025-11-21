import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/equipment_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến Equipment
abstract class EquipmentDataSource {
  /// Lấy danh sách tất cả equipments
  Future<ApiResponse<List<EquipmentModel>>> getAllEquipments();
}

class EquipmentDataSourceImpl implements EquipmentDataSource {
  final ApiClient apiClient;

  EquipmentDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<EquipmentModel>>> getAllEquipments() async {
    try {
      final response = await apiClient.get<List<EquipmentModel>>(
        Endpoints.getEquipments,
        requiresAuth: false,
        parser: (json) {
          // Parse list từ JSON
          if (json is List) {
            return json
                .map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <EquipmentModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<EquipmentModel>>.error(
        "Lấy danh sách equipments thất bại: ${e.toString()}",
      );
    }
  }
}
