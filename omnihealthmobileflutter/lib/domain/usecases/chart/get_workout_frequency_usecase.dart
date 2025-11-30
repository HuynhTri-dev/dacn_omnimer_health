import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/chart_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/workout_frequency_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetWorkoutFrequencyUseCase
    implements UseCase<ApiResponse<List<WorkoutFrequencyEntity>>, NoParams> {
  final ChartRepositoryAbs repository;

  GetWorkoutFrequencyUseCase(this.repository);

  @override
  Future<ApiResponse<List<WorkoutFrequencyEntity>>> call(NoParams params) {
    return repository.getWorkoutFrequency();
  }
}
