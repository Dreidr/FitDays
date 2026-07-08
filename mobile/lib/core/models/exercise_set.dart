class ExerciseSet {
  ExerciseSet({
    required this.reps,
    this.weightKg,
  });

  int reps;
  double? weightKg;

  ExerciseSet copy() {
    return ExerciseSet(
      reps: reps,
      weightKg: weightKg,
    );
  }
}