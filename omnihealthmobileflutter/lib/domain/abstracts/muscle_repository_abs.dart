import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/muscle_entity.dart';

abstract class MuscleRepositoryAbs {
  Future<ApiResponse<MuscleEntity>> getMuscleById(String id);
}
