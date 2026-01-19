class UserProfile {
  final String? name;

  // ✅ make these optional for MVP
  final String? gender;
  final int? age;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final String? workoutPlan;
  final int? workoutDuration; // minutes
  final double? weightKg;
  final List<String> workoutDays;

  // ✅ identity fields
  final String email;

  // ⚠️ test-only
  final String? password;

  const UserProfile({
    this.name,
    required this.email,

    this.gender,
    this.age,
    this.fitnessGoal,
    this.fitnessLevel,
    this.workoutPlan,
    this.workoutDuration,
    this.weightKg,
    this.workoutDays = const [],

    this.password,
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
    String? email,
    String? password,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,

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
        "email": email,
        "password": password, // ⚠️ test-only
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      gender: json["gender"] as String?,
      age: json["age"] as int?,
      fitnessGoal: json["fitnessGoal"] as String?,
      fitnessLevel: json["fitnessLevel"] as String?,
      workoutPlan: json["workoutPlan"] as String?,
      workoutDuration: json["workoutDuration"] as int?,
      weightKg: (json["weightKg"] as num?)?.toDouble(),
      workoutDays: List<String>.from((json["workoutDays"] ?? const []) as List),
      email: (json["email"] ?? "") as String,
      password: json["password"] as String?, // ⚠️ test-only
    );
  }
}
