class WorkoutHistory {
  final String workoutId;
  final String workoutName;
  final int durationMinutes;
  final DateTime completedAt;

  WorkoutHistory({
    required this.workoutId,
    required this.workoutName,
    required this.durationMinutes,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'workoutName': workoutName,
      'durationMinutes': durationMinutes,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory WorkoutHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutHistory(
      workoutId: json['workoutId'],
      workoutName: json['workoutName'],
      durationMinutes: json['durationMinutes'],
      completedAt: DateTime.parse(
        json['completedAt'],
      ),
    );
  }
}