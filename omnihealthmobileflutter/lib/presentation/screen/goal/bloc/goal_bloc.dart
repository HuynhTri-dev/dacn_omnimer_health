import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/create_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/delete_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/update_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/get_goal_by_id_usecase.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final CreateGoalUseCase _createGoalUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final DeleteGoalUseCase _deleteGoalUseCase;
  final GetGoalByIdUseCase _getGoalByIdUseCase;

  GoalBloc({
    required CreateGoalUseCase createGoalUseCase,
    required UpdateGoalUseCase updateGoalUseCase,
    required DeleteGoalUseCase deleteGoalUseCase,
    required GetGoalByIdUseCase getGoalByIdUseCase,
  }) : _createGoalUseCase = createGoalUseCase,
       _updateGoalUseCase = updateGoalUseCase,
       _deleteGoalUseCase = deleteGoalUseCase,
       _getGoalByIdUseCase = getGoalByIdUseCase,
       super(GoalLoading()) {
    on<GetGoalByIdEvent>(_onGetGoalById);
    on<CreateGoalEvent>(_onCreateGoal);
    on<UpdateGoalEvent>(_onUpdateGoal);
    on<DeleteGoalEvent>(_onDeleteGoal);
  }

  Future<void> _onGetGoalById(
    GetGoalByIdEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final response = await _getGoalByIdUseCase(event.id);
      if (response.success && response.data != null) {
        emit(GoalLoaded(response.data!));
      } else {
        emit(GoalError(response.message));
      }
    } catch (e) {
      emit(GoalError('Lấy chi tiết mục tiêu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onCreateGoal(
    CreateGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final response = await _createGoalUseCase(event.goal);
      if (response.success && response.data != null) {
        emit(GoalOperationSuccess(response.data!));
      } else {
        emit(GoalError(response.message));
      }
    } catch (e) {
      emit(GoalError('Tạo mục tiêu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final response = await _updateGoalUseCase(event.goal);
      if (response.success && response.data != null) {
        emit(GoalOperationSuccess(response.data!));
      } else {
        emit(GoalError(response.message));
      }
    } catch (e) {
      emit(GoalError('Cập nhật mục tiêu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoalEvent event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final response = await _deleteGoalUseCase(event.goalId);
      if (response.success) {
        emit(const GoalDeleted(noGoalsLeft: false));
      } else {
        emit(GoalError(response.message));
      }
    } catch (e) {
      emit(GoalError('Xóa mục tiêu thất bại: ${e.toString()}'));
    }
  }
}
