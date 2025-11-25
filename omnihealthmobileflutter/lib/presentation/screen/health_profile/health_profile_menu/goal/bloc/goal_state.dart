import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

class GoalLoading extends GoalState {}

class GoalsLoaded extends GoalState {
  final List<GoalEntity> goals;

  const GoalsLoaded(this.goals);

  @override
  List<Object?> get props => [goals];
}

class GoalOperationSuccess extends GoalState {
  final GoalEntity goal;

  const GoalOperationSuccess(this.goal);

  @override
  List<Object?> get props => [goal];
}

class GoalDeleted extends GoalState {
  final bool noGoalsLeft;

  const GoalDeleted({this.noGoalsLeft = false});

  @override
  List<Object?> get props => [noGoalsLeft];
}

class GoalError extends GoalState {
  final String message;

  const GoalError(this.message);

  @override
  List<Object?> get props => [message];
}
