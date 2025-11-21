class GoalEntity {
  final String id;
  final String goalType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String frequency;

  GoalEntity({
    required this.id,
    required this.goalType,
    this.startDate,
    this.endDate,
    required this.frequency,
  });
}