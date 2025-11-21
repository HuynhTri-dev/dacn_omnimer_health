import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';

/// Abstract repository interface cho BodyPart
/// Định nghĩa các method cần implement
abstract class BodyPartRepositoryAbs {
  /// Lấy danh sách tất cả body parts
  Future<ApiResponse<List<BodyPartEntity>>> getAllBodyParts();
}
