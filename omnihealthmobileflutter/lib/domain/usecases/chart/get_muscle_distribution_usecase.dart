import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/chart_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetMuscleDistributionUseCase
    implements UseCase<ApiResponse<List<MuscleDistributionEntity>>, NoParams> {
  final ChartRepositoryAbs repository;

  GetMuscleDistributionUseCase(this.repository);

  @override
  Future<ApiResponse<List<MuscleDistributionEntity>>> call(NoParams params) {
    return repository.getMuscleDistribution();
  }
}
