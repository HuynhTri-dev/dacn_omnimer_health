import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class TargetMetricEntity extends Equatable {
  final String metricName;
  final double value;
  final String? unit;

  const TargetMetricEntity({
    required this.metricName,
    required this.value,
    this.unit,
  });

  @override
  List<Object?> get props => [metricName, value, unit];
}

class RepeatMetadataEntity extends Equatable {
  final String frequency; // "daily" | "weekly" | "monthly"
  final int? interval;
  final List<int>? daysOfWeek;

  const RepeatMetadataEntity({
    required this.frequency,
    this.interval,
    this.daysOfWeek,
  });

  @override
  List<Object?> get props => [frequency, interval, daysOfWeek];
}

class GoalEntity extends Equatable {
  final String? id;
  final String userId;
  final GoalTypeEnum goalType;
  final DateTime startDate;
  final DateTime endDate;
  final RepeatMetadataEntity? repeat;
  final List<TargetMetricEntity> targetMetric;

  const GoalEntity({
    this.id,
    required this.userId,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    this.repeat,
    required this.targetMetric,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    goalType,
    startDate,
    endDate,
    repeat,
    targetMetric,
  ];

  GoalEntity copyWith({
    String? id,
    String? userId,
    GoalTypeEnum? goalType,
    DateTime? startDate,
    DateTime? endDate,
    RepeatMetadataEntity? repeat,
    List<TargetMetricEntity>? targetMetric,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeat: repeat ?? this.repeat,
      targetMetric: targetMetric ?? this.targetMetric,
    );
  }
}
