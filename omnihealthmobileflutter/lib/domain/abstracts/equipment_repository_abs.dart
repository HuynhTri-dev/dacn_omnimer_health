import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';

/// Abstract repository interface cho Equipment
/// Định nghĩa các method cần implement
abstract class EquipmentRepositoryAbs {
  /// Lấy danh sách tất cả equipments
  Future<ApiResponse<List<EquipmentEntity>>> getAllEquipments();
}
