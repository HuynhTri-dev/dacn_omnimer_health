import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_template_model.dart';

abstract class AIRemoteDataSource {
  Future<ApiResponse<WorkoutTemplateModel>> recommendWorkout({
    List<String>? bodyPartIds,
    List<String>? equipmentIds,
    List<String>? exerciseCategoryIds,
    List<String>? exerciseTypeIds,
    List<String>? muscleIds,
    LocationEnum? location,
    required int k,
  });
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final ApiClient apiClient;

  AIRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<WorkoutTemplateModel>> recommendWorkout({
    List<String>? bodyPartIds,
    List<String>? equipmentIds,
    List<String>? exerciseCategoryIds,
    List<String>? exerciseTypeIds,
    List<String>? muscleIds,
    LocationEnum? location,
    required int k,
  }) async {
    // Assuming GET request with query params or POST with body.
    // Given the complexity of params, POST is more likely, but the route said GET.
    // If GET, we need to serialize lists.
    // Let's assume GET with query params for now as per route definition.

    final body = {
      if (bodyPartIds != null) 'bodyPartIds': bodyPartIds,
      if (equipmentIds != null) 'equipmentIds': equipmentIds,
      if (exerciseCategoryIds != null)
        'exerciseCategoryIds': exerciseCategoryIds,
      if (exerciseTypeIds != null) 'exerciseTypeIds': exerciseTypeIds,
      if (muscleIds != null) 'muscleIds': muscleIds,
      if (location != null) 'location': location.asString,
      'k': k,
    };

    return await apiClient.post<WorkoutTemplateModel>(
      Endpoints.getAiRecommendations,
      data: body,
      parser: (json) =>
          WorkoutTemplateModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
