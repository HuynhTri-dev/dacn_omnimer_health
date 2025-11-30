import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';

class GoalProgressModel {
  final String status;
  final int count;

  GoalProgressModel({required this.status, required this.count});

  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    return GoalProgressModel(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'count': count};
  }

  GoalProgressEntity toEntity() {
    return GoalProgressEntity(status: status, count: count);
  }
}
