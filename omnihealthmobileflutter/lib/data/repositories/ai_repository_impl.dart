import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/ai_remote_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/ai_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

class AIRepositoryImpl implements AIRepositoryAbs {
  final AIRemoteDataSource remoteDataSource;

  AIRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> recommendWorkout({
    required List<String> bodyPartIds,
    required List<String> equipmentIds,
    required List<String> exerciseCategoryIds,
    required List<String> exerciseTypeIds,
    required List<String> muscleIds,
    required String location,
  }) async {
    final response = await remoteDataSource.recommendWorkout(
      bodyPartIds: bodyPartIds,
      equipmentIds: equipmentIds,
      exerciseCategoryIds: exerciseCategoryIds,
      exerciseTypeIds: exerciseTypeIds,
      muscleIds: muscleIds,
      location: location,
    );
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: response.data?.toEntity(), // Model extends Entity
    );
  }
}
