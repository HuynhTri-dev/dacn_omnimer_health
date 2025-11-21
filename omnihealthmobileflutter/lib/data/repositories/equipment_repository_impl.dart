import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/equipment_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/equipment_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';

/// Triển khai EquipmentRepositoryAbs.
/// Chịu trách nhiệm chuyển đổi giữa Domain Entity và Data Model.
class EquipmentRepositoryImpl implements EquipmentRepositoryAbs {
  final EquipmentDataSource equipmentDataSource;

  EquipmentRepositoryImpl({required this.equipmentDataSource});

  @override
  Future<ApiResponse<List<EquipmentEntity>>> getAllEquipments() async {
    try {
      final response = await equipmentDataSource.getAllEquipments();

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <EquipmentEntity>[];

      return ApiResponse<List<EquipmentEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<EquipmentEntity>>.error(
        "Không thể lấy danh sách equipments: ${e.toString()}",
        error: e,
      );
    }
  }
}
