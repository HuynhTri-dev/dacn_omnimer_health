import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/musce_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/muscle_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';

class MuscleRepositoryImpl implements MuscleRepositoryAbs {
  final MuscleDataSource muscleDataSource;

  MuscleRepositoryImpl({required this.muscleDataSource});

  @override
  Future<ApiResponse<MuscleEntity>> getMuscleById(String id) async {
    try {
      final res = await muscleDataSource.getMuscleById(id);

      // Chuyển Model -> Entity
      final entity = res.data?.toEntity();

      return ApiResponse<MuscleEntity>(
        success: res.success,
        message: res.message,
        data: entity,
        error: res.error,
      );
    } catch (e) {
      return ApiResponse<MuscleEntity>.error(
        "Faild to get muscle by id: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<List<MuscleEntity>>> getAllMuscles() async {
    try {
      final response = await muscleDataSource.getAllMuscles();

      // Chuyển Model -> Entity
      final entities = response.data != null
          ? response.data!.map((model) => model.toEntity()).toList()
          : <MuscleEntity>[];

      return ApiResponse<List<MuscleEntity>>(
        success: response.success,
        message: response.message,
        data: entities,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<List<MuscleEntity>>.error(
        "Failed to get all muscles: ${e.toString()}",
        error: e,
      );
    }
  }
}
