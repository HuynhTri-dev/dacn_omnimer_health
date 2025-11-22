import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_type_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến ExerciseType
abstract class ExerciseTypeDataSource {
  /// Lấy danh sách tất cả exercise types
  Future<ApiResponse<List<ExerciseTypeModel>>> getAllExerciseTypes();
}

class ExerciseTypeDataSourceImpl implements ExerciseTypeDataSource {
  final ApiClient apiClient;

  ExerciseTypeDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<ExerciseTypeModel>>> getAllExerciseTypes() async {
    try {
      final response = await apiClient.get<List<ExerciseTypeModel>>(
        Endpoints.getExerciseTypes,
        requiresAuth: false,
        parser: (json) {
          // Parse list từ JSON
          if (json is List) {
            return json
                .map(
                  (e) => ExerciseTypeModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          return <ExerciseTypeModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<ExerciseTypeModel>>.error(
        "Lấy danh sách exercise types thất bại: ${e.toString()}",
      );
    }
  }
}
