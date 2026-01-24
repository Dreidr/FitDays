class PlannedExercise {
  const PlannedExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weightKg,
  });

  final String exerciseId; // ExerciseDB id e.g. "0041"
  final int sets;
  final int reps;
  final double? weightKg;

  String metaText() {
    final w = (weightKg == null) ? "" : " x ${weightKg!.toStringAsFixed(0)}kg";
    return "$sets sets x $reps reps$w";
  }
}
