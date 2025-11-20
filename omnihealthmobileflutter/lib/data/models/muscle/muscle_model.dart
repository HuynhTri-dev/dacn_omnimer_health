class MuscleModel {
  final String id;
  final String name;
  final String description;
  final String image;

  MuscleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory MuscleModel.fromJson(Map<String, dynamic> json) {
    return MuscleModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      image: (json['image'] ?? json['imageUrl'] ?? "") as String,
    );
  }
}
