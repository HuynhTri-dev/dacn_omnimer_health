import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_template_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/delete_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_detail/cubits/workout_template_detail_state.dart';

class WorkoutTemplateDetailCubit extends Cubit<WorkoutTemplateDetailState> {
  final GetWorkoutTemplateByIdUseCase getWorkoutTemplateByIdUseCase;
  final DeleteWorkoutTemplateUseCase deleteWorkoutTemplateUseCase;

  WorkoutTemplateDetailCubit({
    required this.getWorkoutTemplateByIdUseCase,
    required this.deleteWorkoutTemplateUseCase,
  }) : super(const WorkoutTemplateDetailState());

  /// Load workout template detail by ID
  Future<void> loadTemplateDetail(String templateId) async {
    emit(state.copyWith(status: WorkoutTemplateDetailStatus.loading));

    try {
      final response = await getWorkoutTemplateByIdUseCase.call(templateId);

      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: WorkoutTemplateDetailStatus.loaded,
          template: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: WorkoutTemplateDetailStatus.error,
          errorMessage: response.message.isNotEmpty
              ? response.message
              : 'Failed to load template details',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WorkoutTemplateDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Delete workout template by ID
  Future<void> deleteTemplate(String templateId) async {
    emit(state.copyWith(status: WorkoutTemplateDetailStatus.deleting));

    try {
      final response = await deleteWorkoutTemplateUseCase.call(templateId);

      if (response.success) {
        emit(state.copyWith(status: WorkoutTemplateDetailStatus.deleted));
      } else {
        emit(state.copyWith(
          status: WorkoutTemplateDetailStatus.loaded,
          errorMessage: response.message.isNotEmpty
              ? response.message
              : 'Failed to delete template',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WorkoutTemplateDetailStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }
}

