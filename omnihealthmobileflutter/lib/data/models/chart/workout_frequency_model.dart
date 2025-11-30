import 'package:omnihealthmobileflutter/domain/entities/chart/workout_frequency_entity.dart';

class WorkoutFrequencyModel {
  final String period;
  final int count;

  WorkoutFrequencyModel({required this.period, required this.count});

  factory WorkoutFrequencyModel.fromJson(Map<String, dynamic> json) {
    return WorkoutFrequencyModel(
      period: json['period'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  WorkoutFrequencyEntity toEntity() {
    return WorkoutFrequencyEntity(period: period, count: count);
  }
}
