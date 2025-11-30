import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';

class MuscleDistributionModel {
  final String muscleName;
  final int count;

  MuscleDistributionModel({required this.muscleName, required this.count});

  factory MuscleDistributionModel.fromJson(Map<String, dynamic> json) {
    return MuscleDistributionModel(
      muscleName: json['muscleName'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'muscleName': muscleName, 'count': count};
  }

  MuscleDistributionEntity toEntity() {
    return MuscleDistributionEntity(muscleName: muscleName, count: count);
  }
}
