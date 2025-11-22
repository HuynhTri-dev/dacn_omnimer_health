import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/muscle_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';
import '../base_usecase.dart';

class GetAllMuscleTypesUseCase
    implements UseCase<ApiResponse<List<MuscleEntity>>, NoParams> {
  final MuscleRepositoryAbs repository;

  GetAllMuscleTypesUseCase(this.repository);

  @override
  Future<ApiResponse<List<MuscleEntity>>> call(NoParams params) async {
    return await repository.getAllMuscles();
  }
}
