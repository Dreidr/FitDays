class PlanSettings {
  final int workoutsPerWeek;
  final String workoutType;   // "Strength Training"
  final int durationMin;      // 50
  final String fitnessGoal;   // "Maintain Fitness"

  const PlanSettings({
    required this.workoutsPerWeek,
    required this.workoutType,
    required this.durationMin,
    required this.fitnessGoal,
  });

  PlanSettings copyWith({
    int? workoutsPerWeek,
    String? workoutType,
    int? durationMin,
    String? fitnessGoal,
  }) {
    return PlanSettings(
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      workoutType: workoutType ?? this.workoutType,
      durationMin: durationMin ?? this.durationMin,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }
}
