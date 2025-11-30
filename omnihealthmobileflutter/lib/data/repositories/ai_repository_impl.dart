import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/ai_remote_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/ai_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class AIRepositoryImpl implements AIRepositoryAbs {
  final AIRemoteDataSource remoteDataSource;

  AIRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> recommendWorkout({
    List<String>? bodyPartIds,
    List<String>? equipmentIds,
    List<String>? exerciseCategoryIds,
    List<String>? exerciseTypeIds,
    List<String>? muscleIds,
    LocationEnum? location,
    required int k,
  }) async {
    final response = await remoteDataSource.recommendWorkout(
      bodyPartIds: bodyPartIds,
      equipmentIds: equipmentIds,
      exerciseCategoryIds: exerciseCategoryIds,
      exerciseTypeIds: exerciseTypeIds,
      muscleIds: muscleIds,
      location: location,
      k: k,
    );
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: response.data?.toEntity(), // Model extends Entity
    );
  }
}
