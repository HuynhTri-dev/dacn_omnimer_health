import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/role/role_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến Role
abstract class RoleDataSource {
  /// Lấy danh sách tất cả roles (để hiển thị select box)
  Future<ApiResponse<List<RoleSelectBoxModel>>> getRolesForSelectBox();
}

class RoleDataSourceImpl implements RoleDataSource {
  final ApiClient apiClient;

  RoleDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<RoleSelectBoxModel>>> getRolesForSelectBox() async {
    try {
      final response = await apiClient.get<List<RoleSelectBoxModel>>(
        Endpoints.getRoleWithoutAdmin,
        requiresAuth: false,
        parser: (json) {
          // Parse list từ JSON
          if (json is List) {
            return json
                .map(
                  (e) => RoleSelectBoxModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          return <RoleSelectBoxModel>[];
        },
      );

      // Lọc bỏ role có name chứa "admin" (tránh hiển thị admin)
      if (response.success && response.data != null) {
        final filtered = response.data!
            .where((role) => !role.name.toLowerCase().contains('admin'))
            .toList();
        return ApiResponse<List<RoleSelectBoxModel>>(
          success: true,
          message: response.message,
          data: filtered,
        );
      }

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<RoleSelectBoxModel>>.error(
        "Lấy danh sách vai trò thất bại: ${e.toString()}",
      );
    }
  }
}
