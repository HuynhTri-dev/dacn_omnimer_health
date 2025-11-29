import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/ai_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class RecommendWorkoutParams extends Equatable {
  final List<String> bodyPartIds;
  final List<String> equipmentIds;
  final List<String> exerciseCategoryIds;
  final List<String> exerciseTypeIds;
  final List<String> muscleIds;
  final String location;

  const RecommendWorkoutParams({
    required this.bodyPartIds,
    required this.equipmentIds,
    required this.exerciseCategoryIds,
    required this.exerciseTypeIds,
    required this.muscleIds,
    required this.location,
  });

  @override
  List<Object?> get props => [
    bodyPartIds,
    equipmentIds,
    exerciseCategoryIds,
    exerciseTypeIds,
    muscleIds,
    location,
  ];
}

class RecommendWorkoutUseCase
    implements
        UseCase<ApiResponse<WorkoutTemplateEntity>, RecommendWorkoutParams> {
  final AIRepositoryAbs repository;

  RecommendWorkoutUseCase(this.repository);

  @override
  Future<ApiResponse<WorkoutTemplateEntity>> call(
    RecommendWorkoutParams params,
  ) async {
    return await repository.recommendWorkout(
      bodyPartIds: params.bodyPartIds,
      equipmentIds: params.equipmentIds,
      exerciseCategoryIds: params.exerciseCategoryIds,
      exerciseTypeIds: params.exerciseTypeIds,
      muscleIds: params.muscleIds,
      location: params.location,
    );
  }
}
