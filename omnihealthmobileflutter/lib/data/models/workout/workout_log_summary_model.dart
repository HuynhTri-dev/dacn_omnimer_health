import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_summary_entity.dart';
import 'package:omnihealthmobileflutter/data/models/workout/workout_log_model.dart';

/// Model for workout log summary (list view)
class WorkoutLogSummaryModel {
  final String? id;
  final String userId;
  final String? templateId;
  final String workoutName;
  final WorkoutSummaryModel? summary;
  final DateTime? startedAt;

  WorkoutLogSummaryModel({
    this.id,
    required this.userId,
    this.templateId,
    required this.workoutName,
    this.summary,
    this.startedAt,
  });

  factory WorkoutLogSummaryModel.fromJson(Map<String, dynamic> json) {
    // Handle workoutTemplateId as object or string
    String? templateId;
    String workoutName = json['workoutName'] ?? json['name'] ?? '';

    if (json['workoutTemplateId'] is Map<String, dynamic>) {
      final templateData = json['workoutTemplateId'] as Map<String, dynamic>;
      templateId = templateData['_id'];
      if (workoutName.isEmpty) {
        workoutName = templateData['name'] ?? '';
      }
    } else if (json['workoutTemplateId'] is String) {
      templateId = json['workoutTemplateId'];
    } else if (json['templateId'] != null) {
      templateId = json['templateId'];
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return WorkoutLogSummaryModel(
      id: json['_id'],
      userId: json['userId'] ?? '',
      templateId: templateId,
      workoutName: workoutName,
      summary: json['summary'] != null
          ? WorkoutSummaryModel.fromJson(json['summary'])
          : null,
      startedAt:
          parseDate(json['startedAt']) ??
          parseDate(json['timeStart']) ??
          parseDate(json['createdAt']),
    );
  }

  WorkoutLogSummaryEntity toEntity() {
    return WorkoutLogSummaryEntity(
      id: id,
      userId: userId,
      templateId: templateId,
      workoutName: workoutName,
      summary: summary?.toEntity(),
      startedAt: startedAt,
    );
  }
}
