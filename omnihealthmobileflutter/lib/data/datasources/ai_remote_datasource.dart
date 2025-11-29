import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_template_model.dart';

abstract class AIRemoteDataSource {
  Future<ApiResponse<WorkoutTemplateModel>> recommendWorkout({
    required List<String> bodyPartIds,
    required List<String> equipmentIds,
    required List<String> exerciseCategoryIds,
    required List<String> exerciseTypeIds,
    required List<String> muscleIds,
    required String location,
  });
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final ApiClient apiClient;

  AIRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<WorkoutTemplateModel>> recommendWorkout({
    required List<String> bodyPartIds,
    required List<String> equipmentIds,
    required List<String> exerciseCategoryIds,
    required List<String> exerciseTypeIds,
    required List<String> muscleIds,
    required String location,
  }) async {
    // Assuming GET request with query params or POST with body.
    // Given the complexity of params, POST is more likely, but the route said GET.
    // If GET, we need to serialize lists.
    // Let's assume GET with query params for now as per route definition.

    final queryParams = {
      'bodyPartIds': bodyPartIds,
      'equipmentIds': equipmentIds,
      'exerciseCategoryIds': exerciseCategoryIds,
      'exerciseTypeIds': exerciseTypeIds,
      'muscleIds': muscleIds,
      'location': location,
    };

    return await apiClient.get<WorkoutTemplateModel>(
      '/ai/recommend',
      query: queryParams,
      parser: (json) =>
          WorkoutTemplateModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
