class UserProfile {
  final String? name;
  final String? gender;
  final DateTime startDate;
  final int? age;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final String? workoutPlan;
  final int? workoutDuration; // minutes
  final double? weightKg;
  final List<String> workoutDays;

  // ✅ identity fields
  final String email;

  const UserProfile({
    this.name,
    required this.startDate,
    required this.email,
    this.gender,
    this.age,
    this.fitnessGoal,
    this.fitnessLevel,
    this.workoutPlan,
    this.workoutDuration,
    this.weightKg,
    this.workoutDays = const [],
  });

  UserProfile copyWith({
    String? name,
    DateTime? startDate,
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
      startDate: startDate ?? this.startDate,
      email: email ?? this.email,
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
    "startDate": startDate.toIso8601String(),
    "gender": gender,
    "age": age,
    "fitnessGoal": fitnessGoal,
    "fitnessLevel": fitnessLevel,
    "workoutPlan": workoutPlan,
    "workoutDuration": workoutDuration,
    "weightKg": weightKg,
    "workoutDays": workoutDays,
    "email": email,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime parseStartDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        final dt = DateTime.parse(v).toLocal();
        return DateTime(dt.year, dt.month, dt.day); // ✅ date-only
      }
      // fallback if old profiles don't have startDate yet
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    return UserProfile(
      name: json['name'] as String?,
      startDate: parseStartDate(json["startDate"]),
      gender: json["gender"] as String?,
      age: json["age"] as int?,
      fitnessGoal: json["fitnessGoal"] as String?,
      fitnessLevel: json["fitnessLevel"] as String?,
      workoutPlan: json["workoutPlan"] as String?,
      workoutDuration: json["workoutDuration"] as int?,
      weightKg: (json["weightKg"] as num?)?.toDouble(),
      workoutDays: List<String>.from((json["workoutDays"] ?? const []) as List),
      email: (json["email"] ?? "") as String,
    );
  }
}
