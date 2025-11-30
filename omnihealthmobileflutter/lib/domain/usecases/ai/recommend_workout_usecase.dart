import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/ai_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class RecommendWorkoutParams extends Equatable {
  final List<String>? bodyPartIds;
  final List<String>? equipmentIds;
  final List<String>? exerciseCategoryIds;
  final List<String>? exerciseTypeIds;
  final List<String>? muscleIds;
  final LocationEnum? location;
  final int k;

  const RecommendWorkoutParams({
    this.bodyPartIds,
    this.equipmentIds,
    this.exerciseCategoryIds,
    this.exerciseTypeIds,
    this.muscleIds,
    this.location,
    this.k = 5,
  });

  @override
  List<Object?> get props => [
    bodyPartIds,
    equipmentIds,
    exerciseCategoryIds,
    exerciseTypeIds,
    muscleIds,
    location,
    k,
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
      k: params.k,
    );
  }
}
