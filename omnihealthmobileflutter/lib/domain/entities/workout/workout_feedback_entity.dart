class WorkoutFeedbackEntity {
  final String? id;
  final String workoutId;
  final int? suitability;
  final bool? workoutGoalAchieved;
  final bool? targetMuscleFelt;
  final String? injuryOrPainNotes;
  final List<String>? exerciseNotSuitable;
  final String? additionalNotes;
  final DateTime? createdAt;

  WorkoutFeedbackEntity({
    this.id,
    required this.workoutId,
    this.suitability,
    this.workoutGoalAchieved,
    this.targetMuscleFelt,
    this.injuryOrPainNotes,
    this.exerciseNotSuitable,
    this.additionalNotes,
    this.createdAt,
  });
}
