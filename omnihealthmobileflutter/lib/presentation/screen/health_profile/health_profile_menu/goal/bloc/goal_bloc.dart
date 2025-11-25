import 'package:bloc/bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/create_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/delete_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/get_goals_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/update_goal_usecase.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GetGoalsUseCase _getGoalsUseCase;
  final CreateGoalUseCase _createGoalUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final DeleteGoalUseCase _deleteGoalUseCase;

  GoalBloc({
    required GetGoalsUseCase getGoalsUseCase,
    required CreateGoalUseCase createGoalUseCase,
    required UpdateGoalUseCase updateGoalUseCase,
    required DeleteGoalUseCase deleteGoalUseCase,
  })  : _getGoalsUseCase = getGoalsUseCase,
        _createGoalUseCase = createGoalUseCase,
        _updateGoalUseCase = updateGoalUseCase,
        _deleteGoalUseCase = deleteGoalUseCase,
        super(GoalLoading()) {
    on<LoadGoalsEvent>(_onLoadGoals);
    on<CreateGoalEvent>(_onCreateGoal);
    on<UpdateGoalEvent>(_onUpdateGoal);
    on<DeleteGoalEvent>(_onDeleteGoal);
  }

  Future<void> _onLoadGoals(LoadGoalsEvent event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final goals = await _getGoalsUseCase(event.userId);
      emit(GoalsLoaded(goals));
    } catch (e) {
      emit(GoalError('Không thể tải mục tiêu: ${e.toString()}'));
    }
  }

  Future<void> _onCreateGoal(CreateGoalEvent event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final goal = await _createGoalUseCase(event.goal);
      emit(GoalOperationSuccess(goal));
      add(LoadGoalsEvent(event.goal.userId));
    } catch (e) {
      emit(GoalError('Tạo mục tiêu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoalEvent event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final goal = await _updateGoalUseCase(event.goal);
      emit(GoalOperationSuccess(goal));
      add(LoadGoalsEvent(event.goal.userId));
    } catch (e) {
      emit(GoalError('Cập nhật mục tiêu thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteGoal(DeleteGoalEvent event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      await _deleteGoalUseCase(event.goalId);
      // After deletion, reload goals to check if list is empty
      // For that, get userId from somewhere or design differently
      // Here assume userId is available through a method, or pass with event, update accordingly.
      // For now, just emit success with noGoalsLeft false, consuming widget should trigger reload

      emit(const GoalDeleted(noGoalsLeft: false));
    } catch (e) {
      emit(GoalError('Xóa mục tiêu thất bại: ${e.toString()}'));
    }
  }
}