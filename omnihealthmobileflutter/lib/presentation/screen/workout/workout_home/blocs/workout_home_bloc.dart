import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_stats_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/delete_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_user_workout_templates_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_weekly_workout_stats_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_templates_usecase.dart';
import 'package:omnihealthmobileflutter/utils/query_util/default_query_entity.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'workout_home_event.dart';
import 'workout_home_state.dart';

class WorkoutHomeBloc extends Bloc<WorkoutHomeEvent, WorkoutHomeState> {
  final GetWeeklyWorkoutStatsUseCase getWeeklyWorkoutStatsUseCase;
  final GetWorkoutTemplatesUseCase getWorkoutTemplatesUseCase;
  final GetUserWorkoutTemplatesUseCase getUserWorkoutTemplatesUseCase;
  final DeleteWorkoutTemplateUseCase deleteWorkoutTemplateUseCase;

  WorkoutHomeBloc({
    required this.getWeeklyWorkoutStatsUseCase,
    required this.getWorkoutTemplatesUseCase,
    required this.getUserWorkoutTemplatesUseCase,
    required this.deleteWorkoutTemplateUseCase,
  }) : super(const WorkoutHomeState()) {
    on<LoadInitialWorkoutData>(_onLoadInitialData);
    on<LoadWorkoutTemplates>(_onLoadWorkoutTemplates);
    on<LoadUserWorkoutTemplates>(_onLoadUserWorkoutTemplates);
    on<DeleteWorkoutTemplate>(_onDeleteWorkoutTemplate);
    on<RefreshWorkoutData>(_onRefreshWorkoutData);
  }

  Future<void> _onLoadInitialData(
    LoadInitialWorkoutData event,
    Emitter<WorkoutHomeState> emit,
  ) async {
    logger.i('[WorkoutHomeBloc] _onLoadInitialData called');
    emit(state.copyWith(status: WorkoutHomeStatus.loading));

    try {
      // Load stats and templates in parallel
      final results = await Future.wait([
        getWeeklyWorkoutStatsUseCase(NoParams()),
        getUserWorkoutTemplatesUseCase(NoParams()),
      ]);

      final statsResponse = results[0] as ApiResponse<WorkoutStatsEntity>;
      final templatesResponse =
          results[1] as ApiResponse<List<WorkoutTemplateEntity>>;

      logger.i(
        '[WorkoutHomeBloc] Templates response success: ${templatesResponse.success}',
      );
      logger.i(
        '[WorkoutHomeBloc] Templates count from API: ${templatesResponse.data?.length ?? 0}',
      );

      if (templatesResponse.data != null) {
        for (var i = 0; i < templatesResponse.data!.length; i++) {
          logger.i(
            '[WorkoutHomeBloc] Template $i: ${templatesResponse.data![i].name}',
          );
        }
      }

      if (statsResponse.success && templatesResponse.success) {
        emit(
          state.copyWith(
            status: WorkoutHomeStatus.loaded,
            weeklyStats: statsResponse.data,
            templates: templatesResponse.data ?? [],
          ),
        );
        logger.i(
          '[WorkoutHomeBloc] Emitted state with ${state.templates.length} templates',
        );
      } else {
        emit(
          state.copyWith(
            status: WorkoutHomeStatus.error,
            errorMessage: 'Failed to load workout data',
          ),
        );
      }
    } catch (e) {
      logger.e('[WorkoutHomeBloc] Error loading data: $e');
      emit(
        state.copyWith(
          status: WorkoutHomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadWorkoutTemplates(
    LoadWorkoutTemplates event,
    Emitter<WorkoutHomeState> emit,
  ) async {
    try {
      final query = DefaultQueryEntity(page: 1, limit: 50);

      final response = await getWorkoutTemplatesUseCase(query);

      if (response.success) {
        emit(state.copyWith(templates: response.data ?? []));
      } else {
        emit(state.copyWith(errorMessage: response.message));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadUserWorkoutTemplates(
    LoadUserWorkoutTemplates event,
    Emitter<WorkoutHomeState> emit,
  ) async {
    try {
      final response = await getUserWorkoutTemplatesUseCase(NoParams());

      if (response.success) {
        emit(state.copyWith(templates: response.data ?? []));
      } else {
        emit(state.copyWith(errorMessage: response.message));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteWorkoutTemplate(
    DeleteWorkoutTemplate event,
    Emitter<WorkoutHomeState> emit,
  ) async {
    try {
      final response = await deleteWorkoutTemplateUseCase(event.templateId);

      if (response.success) {
        // Remove the deleted template from the list
        final updatedTemplates = state.templates
            .where((template) => template.id != event.templateId)
            .toList();

        emit(state.copyWith(templates: updatedTemplates));
      } else {
        emit(state.copyWith(errorMessage: response.message));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshWorkoutData(
    RefreshWorkoutData event,
    Emitter<WorkoutHomeState> emit,
  ) async {
    logger.i('[WorkoutHomeBloc] _onRefreshWorkoutData called');
    // Reload data directly (not setting loading state to avoid UI flicker)
    try {
      final results = await Future.wait([
        getWeeklyWorkoutStatsUseCase(NoParams()),
        getUserWorkoutTemplatesUseCase(NoParams()),
      ]);

      final statsResponse = results[0] as ApiResponse<WorkoutStatsEntity>;
      final templatesResponse =
          results[1] as ApiResponse<List<WorkoutTemplateEntity>>;

      logger.i(
        '[WorkoutHomeBloc] Refresh - Templates count: ${templatesResponse.data?.length ?? 0}',
      );

      if (statsResponse.success && templatesResponse.success) {
        emit(
          state.copyWith(
            status: WorkoutHomeStatus.loaded,
            weeklyStats: statsResponse.data,
            templates: templatesResponse.data ?? [],
          ),
        );
        logger.i(
          '[WorkoutHomeBloc] Refresh - Emitted state with ${templatesResponse.data?.length ?? 0} templates',
        );
      }
    } catch (e) {
      logger.e('[WorkoutHomeBloc] Refresh error: $e');
      // Silently fail on refresh, keep current data
    }
  }
}
