import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoalsEvent extends GoalEvent {
  final String userId;

  const LoadGoalsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateGoalEvent extends GoalEvent {
  final GoalEntity goal;

  const CreateGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoalEvent extends GoalEvent {
  final GoalEntity goal;

  const UpdateGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteGoalEvent extends GoalEvent {
  final String goalId;

  const DeleteGoalEvent(this.goalId);

  @override
  List<Object?> get props => [goalId];
}