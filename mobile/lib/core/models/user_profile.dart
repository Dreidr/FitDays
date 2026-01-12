class UserProfile {
  final String name;
  final String gender;
  final int age;
  final String fitnessGoal;
  final String fitnessLevel;
  final String workoutPlan;
  final int workoutDuration; // minutes
  final double weightKg;
  final List<String> workoutDays;

  const UserProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.fitnessGoal,
    required this.fitnessLevel,
    required this.workoutPlan,
    required this.workoutDuration,
    required this.weightKg,
    required this.workoutDays,
  });

  UserProfile copyWith({
    String? name,
    String? gender,
    int? age,
    String? fitnessGoal,
    String? fitnessLevel,
    String? workoutPlan,
    int? workoutDuration,
    double? weightKg,
    List<String>? workoutDays,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      workoutDuration: workoutDuration ?? this.workoutDuration,
      weightKg: weightKg ?? this.weightKg,
      workoutDays: workoutDays ?? this.workoutDays,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "gender": gender,
        "age": age,
        "fitnessGoal": fitnessGoal,
        "fitnessLevel": fitnessLevel,
        "workoutPlan": workoutPlan,
        "workoutDuration": workoutDuration,
        "weightKg": weightKg,
        "workoutDays": workoutDays,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json["name"] ?? "") as String,
      gender: (json["gender"] ?? "") as String,
      age: (json["age"] ?? 0) as int,
      fitnessGoal: (json["fitnessGoal"] ?? "") as String,
      fitnessLevel: (json["fitnessLevel"] ?? "") as String,
      workoutPlan: (json["workoutPlan"] ?? "") as String,
      workoutDuration: (json["workoutDuration"] ?? 0) as int,
      weightKg: (json["weightKg"] ?? 0.0).toDouble(),
      workoutDays: List<String>.from((json["workoutDays"] ?? const []) as List),
    );
  }
}
