import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_detail_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';

/// Repository interface for Exercise domain logic.
/// Bridges between Domain Entities and Data Source Models.
/// All implementations should be in the Data layer.
abstract class ExerciseRepositoryAbs {
  /// Get all exercises from the server.
  /// Returns ApiResponse<List<ExerciseListEntity>> containing list of exercises or error message.
  Future<ApiResponse<List<ExerciseListEntity>>> getExercises(
    DefaultQueryEntity query,
  );

  /// Get a specific exercise by ID with complete details.
  /// Returns ApiResponse<ExerciseDetailEntity> containing the exercise details or error message.
  Future<ApiResponse<ExerciseDetailEntity>> getExerciseById(String id);
}
