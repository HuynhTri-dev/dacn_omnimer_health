import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_body_parts_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_equipments_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_categories_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_types_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_muscles_usecase.dart';

// State
enum TemplateDetailsStatus { initial, loading, loaded, error }

class TemplateDetailsState extends Equatable {
  final TemplateDetailsStatus status;
  final List<BodyPartEntity> bodyParts;
  final List<EquipmentEntity> equipments;
  final List<ExerciseCategoryEntity> exerciseCategories;
  final List<ExerciseTypeEntity> exerciseTypes;
  final List<MuscleEntity> muscles;
  final String? errorMessage;

  const TemplateDetailsState({
    this.status = TemplateDetailsStatus.initial,
    this.bodyParts = const [],
    this.equipments = const [],
    this.exerciseCategories = const [],
    this.exerciseTypes = const [],
    this.muscles = const [],
    this.errorMessage,
  });

  TemplateDetailsState copyWith({
    TemplateDetailsStatus? status,
    List<BodyPartEntity>? bodyParts,
    List<EquipmentEntity>? equipments,
    List<ExerciseCategoryEntity>? exerciseCategories,
    List<ExerciseTypeEntity>? exerciseTypes,
    List<MuscleEntity>? muscles,
    String? errorMessage,
  }) {
    return TemplateDetailsState(
      status: status ?? this.status,
      bodyParts: bodyParts ?? this.bodyParts,
      equipments: equipments ?? this.equipments,
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      muscles: muscles ?? this.muscles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bodyParts,
        equipments,
        exerciseCategories,
        exerciseTypes,
        muscles,
        errorMessage,
      ];
}

// Cubit
class TemplateDetailsCubit extends Cubit<TemplateDetailsState> {
  final GetAllBodyPartsUseCase getAllBodyPartsUseCase;
  final GetAllEquipmentsUseCase getAllEquipmentsUseCase;
  final GetAllExerciseCategoriesUseCase getAllExerciseCategoriesUseCase;
  final GetAllExerciseTypesUseCase getAllExerciseTypesUseCase;
  final GetAllMuscleTypesUseCase getAllMusclesUseCase;

  TemplateDetailsCubit({
    required this.getAllBodyPartsUseCase,
    required this.getAllEquipmentsUseCase,
    required this.getAllExerciseCategoriesUseCase,
    required this.getAllExerciseTypesUseCase,
    required this.getAllMusclesUseCase,
  }) : super(const TemplateDetailsState());

  Future<void> loadAllData() async {
    emit(state.copyWith(status: TemplateDetailsStatus.loading));

    try {
      // Load all data in parallel
      final results = await Future.wait([
        getAllBodyPartsUseCase(NoParams()),
        getAllEquipmentsUseCase(NoParams()),
        getAllExerciseCategoriesUseCase(NoParams()),
        getAllExerciseTypesUseCase(NoParams()),
        getAllMusclesUseCase(NoParams()),
      ]);

      final bodyPartsResponse = results[0];
      final equipmentsResponse = results[1];
      final categoriesResponse = results[2];
      final typesResponse = results[3];
      final musclesResponse = results[4];

      emit(state.copyWith(
        status: TemplateDetailsStatus.loaded,
        bodyParts: bodyPartsResponse.data as List<BodyPartEntity>? ?? [],
        equipments: equipmentsResponse.data as List<EquipmentEntity>? ?? [],
        exerciseCategories:
            categoriesResponse.data as List<ExerciseCategoryEntity>? ?? [],
        exerciseTypes: typesResponse.data as List<ExerciseTypeEntity>? ?? [],
        muscles: musclesResponse.data as List<MuscleEntity>? ?? [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TemplateDetailsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

