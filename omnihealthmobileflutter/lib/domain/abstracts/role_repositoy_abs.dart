import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/role_entity.dart';

/// Abstract repository interface cho Role
/// Định nghĩa các method cần implement
abstract class RoleRepositoryAbs {
  /// Lấy danh sách tất cả roles
  Future<ApiResponse<List<RoleSelectBoxEntity>>> getRolesForSelectBox();
}
