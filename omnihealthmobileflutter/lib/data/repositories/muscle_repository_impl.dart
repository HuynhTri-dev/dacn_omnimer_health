import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/muscle_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/muscle_entity.dart';

class MuscleRepositoryImpl implements MuscleRepositoryAbs {
  @override
  Future<ApiResponse<MuscleEntity>> getMuscleById(String id) {
    // TODO: implement getMuscleById
    throw UnimplementedError();
  }
}
