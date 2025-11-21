import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_detail_model.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_list_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// Data source chịu trách nhiệm gọi API liên quan đến Exercise
abstract class ExerciseDataSource {
  /// Lấy danh sách tất cả exercises
  Future<ApiResponse<List<ExerciseListModel>>> getExercises(
    DefaultQueryEntity query,
  );

  /// Lấy thông tin chi tiết của một exercise theo ID
  Future<ApiResponse<ExerciseDetailModel>> getExerciseById(String id);
}

class ExerciseDataSourceImpl implements ExerciseDataSource {
  final ApiClient apiClient;

  ExerciseDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<ExerciseListModel>>> getExercises(
    DefaultQueryEntity query,
  ) async {
    try {
      final queryParam = query.toQueryBuilder().build();

      final response = await apiClient.get<List<ExerciseListModel>>(
        Endpoints.exercises,
        query: queryParam,
        parser: (json) {
          // Parse list từ JSON
          if (json is Map<String, dynamic> && json['data'] is List) {
            final list = json['data'] as List<dynamic>;
            return list
                .map(
                  (e) => ExerciseListModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
          return <ExerciseListModel>[];
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<List<ExerciseListModel>>.error(
        "Lấy danh sách bài tập thất bại: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<ExerciseDetailModel>> getExerciseById(String id) async {
    try {
      final response = await apiClient.get<ExerciseDetailModel>(
        Endpoints.getExerciseById(id),
        parser: (json) {
          // Parse single object từ JSON
          if (json is Map<String, dynamic> && json['data'] is Map) {
            return ExerciseDetailModel.fromJson(
              json['data'] as Map<String, dynamic>,
            );
          }
          throw Exception('Invalid response format');
        },
      );

      return response;
    } catch (e) {
      logger.e(e);
      return ApiResponse<ExerciseDetailModel>.error(
        "Lấy thông tin bài tập thất bại: ${e.toString()}",
      );
    }
  }
}
