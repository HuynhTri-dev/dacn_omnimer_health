import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

abstract class WorkoutSessionEvent extends Equatable {
  const WorkoutSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkoutEvent extends WorkoutSessionEvent {
  final WorkoutTemplateEntity template;
  const StartWorkoutEvent(this.template);

  @override
  List<Object?> get props => [template];
}

class PauseWorkoutEvent extends WorkoutSessionEvent {}

class ResumeWorkoutEvent extends WorkoutSessionEvent {}

class ToggleExerciseExpansionEvent extends WorkoutSessionEvent {
  final int exerciseIndex;
  const ToggleExerciseExpansionEvent(this.exerciseIndex);

  @override
  List<Object?> get props => [exerciseIndex];
}

class ToggleSetCompletionEvent extends WorkoutSessionEvent {
  final int exerciseIndex;
  final int setIndex;
  const ToggleSetCompletionEvent(this.exerciseIndex, this.setIndex);

  @override
  List<Object?> get props => [exerciseIndex, setIndex];
}

class SkipRestTimerEvent extends WorkoutSessionEvent {}

class AddRestTimeEvent extends WorkoutSessionEvent {
  final int seconds;
  const AddRestTimeEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class UpdateSetWeightEvent extends WorkoutSessionEvent {
  final int exerciseIndex;
  final int setIndex;
  final double weight;
  const UpdateSetWeightEvent(this.exerciseIndex, this.setIndex, this.weight);

  @override
  List<Object?> get props => [exerciseIndex, setIndex, weight];
}

class UpdateSetRepsEvent extends WorkoutSessionEvent {
  final int exerciseIndex;
  final int setIndex;
  final int reps;
  const UpdateSetRepsEvent(this.exerciseIndex, this.setIndex, this.reps);

  @override
  List<Object?> get props => [exerciseIndex, setIndex, reps];
}

class AddSetEvent extends WorkoutSessionEvent {
  final int exerciseIndex;
  const AddSetEvent(this.exerciseIndex);

  @override
  List<Object?> get props => [exerciseIndex];
}

class RemoveSetEvent extends WorkoutSessionEvent {
  final int exerciseIndex;
  final int setIndex;
  const RemoveSetEvent(this.exerciseIndex, this.setIndex);

  @override
  List<Object?> get props => [exerciseIndex, setIndex];
}

class LogNextSetEvent extends WorkoutSessionEvent {}

class CompleteAllSetsEvent extends WorkoutSessionEvent {}

class FinishWorkoutEvent extends WorkoutSessionEvent {}

class UpdateWorkoutNameEvent extends WorkoutSessionEvent {
  final String name;
  const UpdateWorkoutNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class TickEvent extends WorkoutSessionEvent {
  const TickEvent();
}

class RestTickEvent extends WorkoutSessionEvent {
  const RestTickEvent();
}

class CreateWorkoutFeedbackEvent extends WorkoutSessionEvent {
  final int? suitability;
  final bool? workoutGoalAchieved;
  final bool? targetMuscleFelt;
  final String? injuryOrPainNotes;
  final List<String>? exerciseNotSuitable;
  final String? additionalNotes;

  const CreateWorkoutFeedbackEvent({
    this.suitability,
    this.workoutGoalAchieved,
    this.targetMuscleFelt,
    this.injuryOrPainNotes,
    this.exerciseNotSuitable,
    this.additionalNotes,
  });

  @override
  List<Object?> get props => [
    suitability,
    workoutGoalAchieved,
    targetMuscleFelt,
    injuryOrPainNotes,
    exerciseNotSuitable,
    additionalNotes,
  ];
}

class ResetFeedbackStatusEvent extends WorkoutSessionEvent {}
