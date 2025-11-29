import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

abstract class AIRepositoryAbs {
  Future<ApiResponse<WorkoutTemplateEntity>> recommendWorkout({
    required List<String> bodyPartIds,
    required List<String> equipmentIds,
    required List<String> exerciseCategoryIds,
    required List<String> exerciseTypeIds,
    required List<String> muscleIds,
    required String location,
  });
}
