import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';

abstract class MuscleRepositoryAbs {
  Future<ApiResponse<MuscleEntity>> getMuscleById(String id);

  Future<ApiResponse<List<MuscleEntity>>> getAllMuscles();
}
