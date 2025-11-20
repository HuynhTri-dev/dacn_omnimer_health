class ExerciseModel {
  final String id;
  final String name;
  final String image;
  final List<String> mainMuscles;
  final String equipment;
  final String type;
  final String category;
  final String location;

  final String description;
  final String instructions;
  final int? met;
  final double? rating;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.image,
    required this.mainMuscles,
    required this.equipment,
    required this.type,
    required this.category,
    required this.location,
    required this.description,
    required this.instructions,
    this.met,
    this.rating,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: (json['image'] ?? json['imageUrl'] ?? '') as String,
      mainMuscles: List<String>.from(json['mainMuscles'] ?? []),
      equipment: json['equipment'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      met: json['met'] == null ? null : (json['met'] as num).toInt(),
      rating: json['rating'] == null
          ? null
          : (json['rating'] as num).toDouble(),
    );
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? image,
    List<String>? mainMuscles,
    String? equipment,
    String? type,
    String? category,
    String? location,
    String? description,
    String? instructions,
    int? met,
    double? rating,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      mainMuscles: mainMuscles ?? this.mainMuscles,
      equipment: equipment ?? this.equipment,
      type: type ?? this.type,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      met: met ?? this.met,
      rating: rating ?? this.rating,
    );
  }
}
