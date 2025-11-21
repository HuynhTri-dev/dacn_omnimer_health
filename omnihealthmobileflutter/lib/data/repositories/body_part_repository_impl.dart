import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/body_part_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/body_part_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';

/// Triển khai BodyPartRepositoryAbs.
/// Chịu trách nhiệm chuyển đổi giữa Domain Entity và Data Model.
class BodyPartRepositoryImpl implements BodyPartRepositoryAbs {
  final BodyPartDataSource bodyPartDataSource;

  BodyPartRepositoryImpl({required this.bodyPartDataSource});

  @override
  Future<ApiResponse<List<BodyPartEntity>>> getAllBodyParts() async {
    try {
      final response = await bodyPartDataSource.getAllBodyParts();

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <BodyPartEntity>[];

      return ApiResponse<List<BodyPartEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<BodyPartEntity>>.error(
        "Không thể lấy danh sách body parts: ${e.toString()}",
        error: e,
      );
    }
  }
}
