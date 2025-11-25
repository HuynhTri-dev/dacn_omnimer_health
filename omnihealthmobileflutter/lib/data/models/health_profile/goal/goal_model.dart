import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class GoalModel {
  final String? id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency;

  GoalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.frequency,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: json['id'] as String?,
        userId: json['userId'] as String,
        title: json['title'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        frequency: json['frequency'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'frequency': frequency,
      };

  GoalEntity toEntity() {
    return GoalEntity(
      id: id,
      userId: userId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      frequency: frequency,
    );
  }

  static GoalModel fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      startDate: entity.startDate,
      endDate: entity.endDate,
      frequency: entity.frequency,
    );
  }
}