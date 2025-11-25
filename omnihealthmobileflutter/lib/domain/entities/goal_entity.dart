import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  final String? id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency; // e.g., 'Daily', 'Weekly', 'Monthly'

  const GoalEntity({
    this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.frequency,
  });

  @override
  List<Object?> get props => [id, userId, title, startDate, endDate, frequency];

  GoalEntity copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? frequency,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
    );
  }
}