import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/chart_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetWeightProgressUseCase
    implements UseCase<ApiResponse<List<WeightProgressEntity>>, NoParams> {
  final ChartRepositoryAbs repository;

  GetWeightProgressUseCase(this.repository);

  @override
  Future<ApiResponse<List<WeightProgressEntity>>> call(NoParams params) {
    return repository.getWeightProgress();
  }
}
