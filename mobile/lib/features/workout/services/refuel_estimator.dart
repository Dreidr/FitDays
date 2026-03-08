import 'package:mobile/core/models/user_profile.dart';

class RefuelEstimate {
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final int calories;

  const RefuelEstimate({
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.calories,
  });
}

class RefuelEstimator {
  static double _clamp(double v, double a, double b) =>
      v < a ? a : (v > b ? b : v);

  static String _norm(String? s) => (s ?? "").trim().toLowerCase();

  static bool _strengthGoal(UserProfile? p) {
    final g = _norm(p?.fitnessGoal);
    return g.contains("strength") || g.contains("muscle") || g.contains("hyper");
  }

  static bool _fatLossGoal(UserProfile? p) {
    final g = _norm(p?.fitnessGoal);
    return g.contains("lose") || g.contains("fat") || g.contains("cut");
  }

  static bool _isCardioTitle(String title) {
    final t = _norm(title);
    return t.contains("cardio") || t.contains("hiit") || t.contains("run");
  }

  /// Post-workout targets for the next 1–2 hours (MVP).
  static RefuelEstimate postWorkout({
    required UserProfile? profile,
    required int sessionMinutes,
    required String workoutTitle,
  }) {
    final bw = profile?.weightKg;
    final weight = (bw == null || bw <= 0) ? 70.0 : bw;

    // Protein: 0.25–0.40 g/kg (use goal to bias)
    double proteinPerKg = 0.30;
    if (_strengthGoal(profile)) proteinPerKg = 0.33;
    if (_fatLossGoal(profile)) proteinPerKg = 0.35;

    final protein = (weight * proteinPerKg).round().clamp(20, 60);

    // Carbs: 0.5–1.0 g/kg depending on duration/type
    double carbsPerKg = _isCardioTitle(workoutTitle) ? 0.75 : 0.55;

    // Scale with duration: 30–70min ~ 0.9–1.2 factor
    final durFactor = _clamp(0.9 + ((sessionMinutes - 30) / 200), 0.85, 1.25);
    carbsPerKg *= durFactor;

    if (_fatLossGoal(profile)) carbsPerKg *= 0.85;
    if (_strengthGoal(profile)) carbsPerKg *= 1.05;

    final carbs = (weight * carbsPerKg).round().clamp(20, 120);

    // Fats: keep low/moderate post-workout
    double fatsPerKg = _fatLossGoal(profile) ? 0.12 : 0.15;
    final fats = (weight * fatsPerKg).round().clamp(5, 25);

    final calories = (protein * 4) + (carbs * 4) + (fats * 9);

    return RefuelEstimate(
      proteinG: protein,
      carbsG: carbs,
      fatsG: fats,
      calories: calories,
    );
  }
}
