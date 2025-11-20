import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/muscle_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/muscle_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetMuscleByIdUsecase
    implements UseCase<ApiResponse<MuscleEntity>, String> {
  final MuscleRepositoryAbs repository;

  GetMuscleByIdUsecase(this.repository);

  @override
  Future<ApiResponse<MuscleEntity>> call(String id) async {
    return await repository.getMuscleById(id);
  }
}
