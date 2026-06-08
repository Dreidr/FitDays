class Exercise {
  final String id;
  final String name;
  final String category;
  final String muscleGroup;
  final String video;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.video,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      muscleGroup: json['muscleGroup'],
      video: json['video'],
    );
  }
}