import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/chart_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class GetCaloriesBurnedUseCase
    implements UseCase<ApiResponse<List<CaloriesBurnedEntity>>, NoParams> {
  final ChartRepositoryAbs repository;

  GetCaloriesBurnedUseCase(this.repository);

  @override
  Future<ApiResponse<List<CaloriesBurnedEntity>>> call(NoParams params) {
    return repository.getCaloriesBurned();
  }
}
