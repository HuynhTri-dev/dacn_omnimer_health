import 'package:equatable/equatable.dart';

class ExerciseRatingEntity extends Equatable {
  final String? id; // _id từ MongoDB (có thể null khi tạo mới)
  final String exerciseId;
  final String userId;
  final double score; // Dùng double để linh hoạt (ví dụ 4.5 sao), dù DB lưu int

  const ExerciseRatingEntity({
    this.id,
    required this.exerciseId,
    required this.userId,
    required this.score,
  });

  @override
  List<Object?> get props => [id, exerciseId, userId, score];
}
