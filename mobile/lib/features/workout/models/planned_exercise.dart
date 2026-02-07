class PlannedExercise {
  const PlannedExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weightKg,
  });

  PlannedExercise copyWith({
    String? exerciseId,
    int? sets,
    int? reps,
    double? weightKg,
    bool clearWeight = false,
  }) {
    return PlannedExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
    );
  }

  Map<String, dynamic> toJson() => {
    "exerciseId": exerciseId,
    "sets": sets,
    "reps": reps,
    "weightKg": weightKg,
  };

  // ✅ ADD THIS
  factory PlannedExercise.fromJson(Map<String, dynamic> json) {
    final w = json["weightKg"];
    return PlannedExercise(
      exerciseId: (json["exerciseId"] ?? "").toString(),
      sets: (json["sets"] as num).toInt(),
      reps: (json["reps"] as num).toInt(),
      weightKg: w == null ? null : (w as num).toDouble(),
    );
  }

  final String exerciseId; // ExerciseDB id e.g. "0041"
  final int sets;
  final int reps;
  final double? weightKg;

  String metaText() {
    final w = (weightKg != null && weightKg! > 0)
        ? " x ${weightKg!.toStringAsFixed(0)}kg"
        : "";
    return "$sets sets x $reps reps$w";
  }
}
