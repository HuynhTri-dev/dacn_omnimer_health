import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class TargetMetricModel {
  final String metricName;
  final double value;
  final String? unit;

  TargetMetricModel({required this.metricName, required this.value, this.unit});

  factory TargetMetricModel.fromJson(Map<String, dynamic> json) =>
      TargetMetricModel(
        metricName: json['metricName'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'metricName': metricName,
    'value': value,
    'unit': unit,
  };

  TargetMetricEntity toEntity() =>
      TargetMetricEntity(metricName: metricName, value: value, unit: unit);

  factory TargetMetricModel.fromEntity(TargetMetricEntity entity) =>
      TargetMetricModel(
        metricName: entity.metricName,
        value: entity.value,
        unit: entity.unit,
      );
}

class RepeatMetadataModel {
  final String frequency;
  final int? interval;
  final List<int>? daysOfWeek;

  RepeatMetadataModel({
    required this.frequency,
    this.interval,
    this.daysOfWeek,
  });

  factory RepeatMetadataModel.fromJson(Map<String, dynamic> json) =>
      RepeatMetadataModel(
        frequency: json['frequency'] as String,
        interval: json['interval'] as int?,
        daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'frequency': frequency,
    'interval': interval,
    'daysOfWeek': daysOfWeek,
  };

  RepeatMetadataEntity toEntity() => RepeatMetadataEntity(
    frequency: frequency,
    interval: interval,
    daysOfWeek: daysOfWeek,
  );

  factory RepeatMetadataModel.fromEntity(RepeatMetadataEntity entity) =>
      RepeatMetadataModel(
        frequency: entity.frequency,
        interval: entity.interval,
        daysOfWeek: entity.daysOfWeek,
      );
}

class GoalModel {
  final String? id;
  final String userId;
  final GoalTypeEnum goalType;
  final DateTime startDate;
  final DateTime endDate;
  final RepeatMetadataModel? repeat;
  final List<TargetMetricModel> targetMetric;

  GoalModel({
    this.id,
    required this.userId,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    this.repeat,
    required this.targetMetric,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json['_id'] as String?,
    userId: json['userId'] as String,
    goalType: GoalTypeEnum.fromString(json['goalType'] as String),
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    repeat: json['repeat'] != null
        ? RepeatMetadataModel.fromJson(json['repeat'])
        : null,
    targetMetric:
        (json['targetMetric'] as List<dynamic>?)
            ?.map((e) => TargetMetricModel.fromJson(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'goalType': goalType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetMetric': targetMetric.map((e) => e.toJson()).toList(),
    };
    if (id != null) data['_id'] = id;
    if (repeat != null) data['repeat'] = repeat!.toJson();
    return data;
  }

  GoalEntity toEntity() {
    return GoalEntity(
      id: id,
      userId: userId,
      goalType: goalType,
      startDate: startDate,
      endDate: endDate,
      repeat: repeat?.toEntity(),
      targetMetric: targetMetric.map((e) => e.toEntity()).toList(),
    );
  }

  static GoalModel fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      goalType: entity.goalType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      repeat: entity.repeat != null
          ? RepeatMetadataModel.fromEntity(entity.repeat!)
          : null,
      targetMetric: entity.targetMetric
          .map((e) => TargetMetricModel.fromEntity(e))
          .toList(),
    );
  }
}
