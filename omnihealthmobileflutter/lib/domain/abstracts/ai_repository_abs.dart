import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

abstract class AIRepositoryAbs {
  Future<ApiResponse<WorkoutTemplateEntity>> recommendWorkout({
    List<String>? bodyPartIds,
    List<String>? equipmentIds,
    List<String>? exerciseCategoryIds,
    List<String>? exerciseTypeIds,
    List<String>? muscleIds,
    LocationEnum? location,
    required int k,
  });
}
