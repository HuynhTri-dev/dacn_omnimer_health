import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_detail_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to get a specific exercise by ID with complete details
class GetExerciseByIdUseCase
    implements UseCase<ApiResponse<ExerciseDetailEntity>, String> {
  final ExerciseRepositoryAbs repository;

  GetExerciseByIdUseCase(this.repository);

  @override
  Future<ApiResponse<ExerciseDetailEntity>> call(String id) async {
    return await repository.getExerciseById(id);
  }
}
