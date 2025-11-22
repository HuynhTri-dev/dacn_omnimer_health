import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_category_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến ExerciseCategory
abstract class ExerciseCategoryDataSource {
  /// Lấy danh sách tất cả exercise categories
  Future<ApiResponse<List<ExerciseCategoryModel>>> getAllExerciseCategories();
}

class ExerciseCategoryDataSourceImpl implements ExerciseCategoryDataSource {
  final ApiClient apiClient;

  ExerciseCategoryDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<ExerciseCategoryModel>>>
  getAllExerciseCategories() async {
    try {
      final response = await apiClient.get<List<ExerciseCategoryModel>>(
        Endpoints.getExerciseCategories,
        requiresAuth: false,
        parser: (json) {
          // Parse list từ JSON
          if (json is List) {
            return json
                .map(
                  (e) =>
                      ExerciseCategoryModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          return <ExerciseCategoryModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<ExerciseCategoryModel>>.error(
        "Lấy danh sách exercise categories thất bại: ${e.toString()}",
      );
    }
  }
}
