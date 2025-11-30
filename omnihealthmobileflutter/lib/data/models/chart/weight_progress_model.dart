import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';

class WeightProgressModel {
  final DateTime date;
  final double weight;

  WeightProgressModel({required this.date, required this.weight});

  factory WeightProgressModel.fromJson(Map<String, dynamic> json) {
    return WeightProgressModel(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'weight': weight};
  }

  WeightProgressEntity toEntity() {
    return WeightProgressEntity(date: date, weight: weight);
  }
}
