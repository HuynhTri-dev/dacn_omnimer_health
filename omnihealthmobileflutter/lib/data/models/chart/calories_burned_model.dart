import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';

class CaloriesBurnedModel {
  final DateTime date;
  final double calories;

  CaloriesBurnedModel({required this.date, required this.calories});

  factory CaloriesBurnedModel.fromJson(Map<String, dynamic> json) {
    return CaloriesBurnedModel(
      date: DateTime.parse(json['date']),
      calories: (json['calories'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'calories': calories};
  }

  CaloriesBurnedEntity toEntity() {
    return CaloriesBurnedEntity(date: date, calories: calories);
  }
}
