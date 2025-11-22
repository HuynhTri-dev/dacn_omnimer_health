import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart'
    as bp;
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart'
    as eq;
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart'
    as ec;
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart'
    as et;
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_body_parts_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_equipments_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_categories_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_types_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_muscles_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercises_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_muscle_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';
import 'exercise_home_event.dart';
import 'exercise_home_state.dart';

class ExerciseHomeBloc extends Bloc<ExerciseHomeEvent, ExerciseHomeState> {
  final GetAllBodyPartsUseCase getAllBodyPartsUseCase;
  final GetAllEquipmentsUseCase getAllEquipmentsUseCase;
  final GetAllExerciseTypesUseCase getAllExerciseTypesUseCase;
  final GetAllExerciseCategoriesUseCase getAllExerciseCategoriesUseCase;
  final GetAllMuscleTypesUseCase getAllMusclesUseCase;
  final GetExercisesUseCase getExercisesUseCase;
  final GetMuscleByIdUsecase getMuscleByIdUsecase;

  ExerciseHomeBloc({
    required this.getAllBodyPartsUseCase,
    required this.getAllEquipmentsUseCase,
    required this.getAllExerciseTypesUseCase,
    required this.getAllExerciseCategoriesUseCase,
    required this.getAllMusclesUseCase,
    required this.getExercisesUseCase,
    required this.getMuscleByIdUsecase,
  }) : super(const ExerciseHomeState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadExercises>(_onLoadExercises);
    on<LoadMoreExercises>(_onLoadMoreExercises);
    on<SearchExercises>(_onSearchExercises);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
    on<SelectMuscleById>(_onSelectMuscleById);
  }

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    emit(state.copyWith(status: ExerciseHomeStatus.loadingFilters));

    try {
      // Load all filter data in parallel
      final results = await Future.wait([
        getAllBodyPartsUseCase(NoParams()),
        getAllEquipmentsUseCase(NoParams()),
        getAllExerciseTypesUseCase(NoParams()),
        getAllExerciseCategoriesUseCase(NoParams()),
        getAllMusclesUseCase(NoParams()),
      ]);

      final bodyPartsResponse = results[0];
      final equipmentsResponse = results[1];
      final exerciseTypesResponse = results[2];
      final categoriesResponse = results[3];
      final musclesResponse = results[4];

      if (bodyPartsResponse.success &&
          equipmentsResponse.success &&
          exerciseTypesResponse.success &&
          categoriesResponse.success &&
          musclesResponse.success) {
        emit(
          state.copyWith(
            status: ExerciseHomeStatus.filtersLoaded,
            bodyParts: (bodyPartsResponse.data ?? []).cast<bp.BodyPartEntity>(),
            equipments: (equipmentsResponse.data ?? [])
                .cast<eq.EquipmentEntity>(),
            exerciseTypes: (exerciseTypesResponse.data ?? [])
                .cast<et.ExerciseTypeEntity>(),
            categories: (categoriesResponse.data ?? [])
                .cast<ec.ExerciseCategoryEntity>(),
            muscles: (musclesResponse.data ?? []).cast<MuscleEntity>(),
          ),
        );

        // Load initial exercises
        add(LoadExercises());
      } else {
        emit(
          state.copyWith(
            status: ExerciseHomeStatus.error,
            errorMessage: 'Failed to load filter data',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseHomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadExercises(
    LoadExercises event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    emit(state.copyWith(status: ExerciseHomeStatus.loadingExercises));

    try {
      final query = _buildQuery(page: 1);
      final response = await getExercisesUseCase(query);

      if (response.success) {
        emit(
          state.copyWith(
            status: ExerciseHomeStatus.exercisesLoaded,
            exercises: response.data,
            currentPage: 1,
            hasMoreExercises: (response.data?.length ?? 0) >= 20,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ExerciseHomeStatus.error,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseHomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreExercises(
    LoadMoreExercises event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    if (!state.hasMoreExercises ||
        state.status == ExerciseHomeStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: ExerciseHomeStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final query = _buildQuery(page: nextPage);
      final response = await getExercisesUseCase(query);

      if (response.success) {
        final newExercises = response.data ?? [];
        emit(
          state.copyWith(
            status: ExerciseHomeStatus.exercisesLoaded,
            exercises: [...state.exercises, ...newExercises],
            currentPage: nextPage,
            hasMoreExercises: newExercises.length >= 20,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ExerciseHomeStatus.error,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ExerciseHomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchExercises(
    SearchExercises event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    emit(
      state.copyWith(
        searchQuery: event.query,
        status: ExerciseHomeStatus.loadingExercises,
      ),
    );

    add(LoadExercises());
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    emit(
      state.copyWith(
        activeLocation: event.location,
        activeEquipmentIds: event.equipmentIds ?? state.activeEquipmentIds,
        activeMuscleIds: event.muscleIds ?? state.activeMuscleIds,
        activeExerciseTypeIds:
            event.exerciseTypeIds ?? state.activeExerciseTypeIds,
        activeCategoryIds: event.categoryIds ?? state.activeCategoryIds,
        status: ExerciseHomeStatus.loadingExercises,
      ),
    );

    add(LoadExercises());
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    emit(
      state.copyWith(
        activeLocation: null,
        activeEquipmentIds: const [],
        activeMuscleIds: const [],
        activeExerciseTypeIds: const [],
        activeCategoryIds: const [],
        searchQuery: null,
        status: ExerciseHomeStatus.loadingExercises,
      ),
    );

    add(LoadExercises());
  }

  Future<void> _onSelectMuscleById(
    SelectMuscleById event,
    Emitter<ExerciseHomeState> emit,
  ) async {
    try {
      final response = await getMuscleByIdUsecase(event.muscleId);

      if (response.success && response.data != null) {
        emit(state.copyWith(selectedMuscle: response.data));
      } else {
        emit(state.copyWith(errorMessage: response.message));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  DefaultQueryEntity _buildQuery({required int page}) {
    final filters = <String, dynamic>{};

    if (state.activeLocation != null) {
      filters['location'] = state.activeLocation!.name;
    }

    if (state.activeEquipmentIds.isNotEmpty) {
      filters['equipmentIds'] = state.activeEquipmentIds;
    }

    if (state.activeMuscleIds.isNotEmpty) {
      filters['muscleIds'] = state.activeMuscleIds;
    }

    if (state.activeExerciseTypeIds.isNotEmpty) {
      filters['exerciseTypes'] = state.activeExerciseTypeIds;
    }

    if (state.activeCategoryIds.isNotEmpty) {
      filters['exerciseCategories'] = state.activeCategoryIds;
    }

    return DefaultQueryEntity(
      page: page,
      limit: 20,
      filter: filters,
      search: state.searchQuery,
    );
  }
}
