import 'package:omnihealthmobileflutter/domain/entities/workout/workout_feedback_entity.dart';

class WorkoutFeedbackModel extends WorkoutFeedbackEntity {
  WorkoutFeedbackModel({
    super.id,
    required super.workoutId,
    super.suitability,
    super.workoutGoalAchieved,
    super.targetMuscleFelt,
    super.injuryOrPainNotes,
    super.exerciseNotSuitable,
    super.additionalNotes,
    super.createdAt,
  });

  factory WorkoutFeedbackModel.fromJson(Map<String, dynamic> json) {
    return WorkoutFeedbackModel(
      id: json['_id'],
      workoutId: json['workoutId'],
      suitability: json['suitability'],
      workoutGoalAchieved: json['workout_goal_achieved'],
      targetMuscleFelt: json['target_muscle_felt'],
      injuryOrPainNotes: json['injury_or_pain_notes'],
      exerciseNotSuitable: json['exercise_not_suitable'] != null
          ? List<String>.from(json['exercise_not_suitable'])
          : null,
      additionalNotes: json['additionalNotes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'suitability': suitability,
      'workout_goal_achieved': workoutGoalAchieved,
      'target_muscle_felt': targetMuscleFelt,
      'injury_or_pain_notes': injuryOrPainNotes,
      'exercise_not_suitable': exerciseNotSuitable,
      'additionalNotes': additionalNotes,
    };
  }
}
