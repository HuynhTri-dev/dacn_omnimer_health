import 'package:equatable/equatable.dart';

abstract class WorkoutHomeEvent extends Equatable {
  const WorkoutHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial data (stats + templates)
class LoadInitialWorkoutData extends WorkoutHomeEvent {}

/// Event to load workout templates
class LoadWorkoutTemplates extends WorkoutHomeEvent {}

/// Event to load user's workout templates
class LoadUserWorkoutTemplates extends WorkoutHomeEvent {}

/// Event to delete workout template
class DeleteWorkoutTemplate extends WorkoutHomeEvent {
  final String templateId;

  const DeleteWorkoutTemplate(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

/// Event to refresh data
class RefreshWorkoutData extends WorkoutHomeEvent {}

