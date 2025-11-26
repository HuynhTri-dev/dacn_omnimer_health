import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class GetGoalByIdEvent extends GoalEvent {
  final String id;

  const GetGoalByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
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
  final String userId;

  const DeleteGoalEvent(this.goalId, this.userId);

  @override
  List<Object?> get props => [goalId, userId];
}
