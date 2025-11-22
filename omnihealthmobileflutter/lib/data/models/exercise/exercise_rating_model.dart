import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_rating_entity.dart';

class ExerciseRatingModel {
  final String? id;
  final String exerciseId;
  final String userId;
  final double score;

  const ExerciseRatingModel({
    this.id,
    required this.exerciseId,
    required this.userId,
    required this.score,
  });

  // --- JSON SERIALIZATION (Data Logic) ---

  /// 1. fromJson: Tạo Model từ JSON
  factory ExerciseRatingModel.fromJson(Map<String, dynamic> json) {
    return ExerciseRatingModel(
      id: json['_id'] as String?,
      exerciseId: json['exerciseId'] as String,
      userId: json['userId'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  /// 2. toJson: Chuyển Model thành JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'exerciseId': exerciseId,
      'userId': userId,
      'score': score,
    };
  }

  // --- MAPPING (Mapper Logic) ---

  /// 3. toEntity: Chuyển từ Model (Data) -> Entity (Domain)
  /// Được gọi trong Repository khi lấy dữ liệu từ API về
  ExerciseRatingEntity toEntity() {
    return ExerciseRatingEntity(
      id: id,
      exerciseId: exerciseId,
      userId: userId,
      score: score,
    );
  }

  /// 4. fromEntity: Chuyển từ Entity (Domain) -> Model (Data)
  /// Được gọi trong Repository khi cần đẩy dữ liệu lên API (POST/PUT)
  factory ExerciseRatingModel.fromEntity(ExerciseRatingEntity entity) {
    return ExerciseRatingModel(
      id: entity.id,
      exerciseId: entity.exerciseId,
      userId: entity.userId,
      score: entity.score,
    );
  }
}
