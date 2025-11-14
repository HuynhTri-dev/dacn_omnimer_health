import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/role_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/role/role_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/role_repositoy_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/role_entity.dart';

/// Triển khai RoleRepositoryAbs.
/// Chịu trách nhiệm chuyển đổi giữa Domain Entity và Data Model.
class RoleRepositoryImpl implements RoleRepositoryAbs {
  final RoleDataSource roleDataSource;

  RoleRepositoryImpl({required this.roleDataSource});

  @override
  Future<ApiResponse<List<RoleSelectBoxEntity>>> getRolesForSelectBox() async {
    try {
      final response = await roleDataSource.getRolesForSelectBox();

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? RoleSelectBoxModel.toEntityList(response.data!)
          : <RoleSelectBoxEntity>[];

      return ApiResponse<List<RoleSelectBoxEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<RoleSelectBoxEntity>>.error(
        "Không thể lấy danh sách vai trò: ${e.toString()}",
        error: e,
      );
    }
  }
}
