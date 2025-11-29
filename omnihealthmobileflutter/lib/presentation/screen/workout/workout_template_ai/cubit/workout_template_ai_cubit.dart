import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/ai/recommend_workout_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_body_parts_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_equipments_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_categories_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_types_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_muscles_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/cubit/workout_template_ai_state.dart';

class WorkoutTemplateAICubit extends Cubit<WorkoutTemplateAIState> {
  final GetAllBodyPartsUseCase getAllBodyPartsUseCase;
  final GetAllEquipmentsUseCase getAllEquipmentsUseCase;
  final GetAllExerciseCategoriesUseCase getAllExerciseCategoriesUseCase;
  final GetAllExerciseTypesUseCase getAllExerciseTypesUseCase;
  final GetAllMuscleTypesUseCase getAllMusclesUseCase;
  final RecommendWorkoutUseCase recommendWorkoutUseCase;

  WorkoutTemplateAICubit({
    required this.getAllBodyPartsUseCase,
    required this.getAllEquipmentsUseCase,
    required this.getAllExerciseCategoriesUseCase,
    required this.getAllExerciseTypesUseCase,
    required this.getAllMusclesUseCase,
    required this.recommendWorkoutUseCase,
  }) : super(const WorkoutTemplateAIState());

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: WorkoutTemplateAIStatus.loading));

    try {
      final results = await Future.wait<dynamic>([
        getAllBodyPartsUseCase(NoParams()),
        getAllEquipmentsUseCase(NoParams()),
        getAllExerciseCategoriesUseCase(NoParams()),
        getAllExerciseTypesUseCase(NoParams()),
        getAllMusclesUseCase(NoParams()),
      ]);

      final bodyPartsResponse = results[0] as ApiResponse<List<BodyPartEntity>>;
      final equipmentsResponse =
          results[1] as ApiResponse<List<EquipmentEntity>>;
      final categoriesResponse =
          results[2] as ApiResponse<List<ExerciseCategoryEntity>>;
      final typesResponse = results[3] as ApiResponse<List<ExerciseTypeEntity>>;
      final musclesResponse = results[4] as ApiResponse<List<MuscleEntity>>;

      emit(
        state.copyWith(
          status: WorkoutTemplateAIStatus.loaded,
          bodyParts: bodyPartsResponse.data ?? [],
          equipments: equipmentsResponse.data ?? [],
          exerciseCategories: categoriesResponse.data ?? [],
          exerciseTypes: typesResponse.data ?? [],
          muscles: musclesResponse.data ?? [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutTemplateAIStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void updateSelectedBodyParts(List<String> ids) {
    emit(state.copyWith(selectedBodyPartIds: ids));
  }

  void updateSelectedEquipments(List<String> ids) {
    emit(state.copyWith(selectedEquipmentIds: ids));
  }

  void updateSelectedCategories(List<String> ids) {
    emit(state.copyWith(selectedExerciseCategoryIds: ids));
  }

  void updateSelectedTypes(List<String> ids) {
    emit(state.copyWith(selectedExerciseTypeIds: ids));
  }

  void updateSelectedMuscles(List<String> ids) {
    emit(state.copyWith(selectedMuscleIds: ids));
  }

  void updateSelectedLocation(LocationEnum location) {
    emit(state.copyWith(selectedLocation: location));
  }

  void updateK(int k) {
    emit(state.copyWith(k: k));
  }

  Future<void> createWorkoutById() async {
    emit(state.copyWith(status: WorkoutTemplateAIStatus.submitting));

    final result = await recommendWorkoutUseCase(
      RecommendWorkoutParams(
        bodyPartIds: state.selectedBodyPartIds.isNotEmpty
            ? state.selectedBodyPartIds
            : null,
        equipmentIds: state.selectedEquipmentIds.isNotEmpty
            ? state.selectedEquipmentIds
            : null,
        exerciseCategoryIds: state.selectedExerciseCategoryIds.isNotEmpty
            ? state.selectedExerciseCategoryIds
            : null,
        exerciseTypeIds: state.selectedExerciseTypeIds.isNotEmpty
            ? state.selectedExerciseTypeIds
            : null,
        muscleIds: state.selectedMuscleIds.isNotEmpty
            ? state.selectedMuscleIds
            : null,
        location: state.selectedLocation != LocationEnum.None
            ? state.selectedLocation
            : null,
        k: state.k,
      ),
    );

    if (result.success) {
      emit(
        state.copyWith(
          status: WorkoutTemplateAIStatus.success,
          recommendedWorkout: result.data,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: WorkoutTemplateAIStatus.failure,
          errorMessage: result.message,
        ),
      );
    }
  }
}
