import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_type_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';
import '../base_usecase.dart';

class GetAllExerciseTypesUseCase
    implements UseCase<ApiResponse<List<ExerciseTypeEntity>>, NoParams> {
  final ExerciseTypeRepositoryAbs repository;

  GetAllExerciseTypesUseCase(this.repository);

  @override
  Future<ApiResponse<List<ExerciseTypeEntity>>> call(NoParams params) async {
    return await repository.getAllExerciseTypes();
  }
}
