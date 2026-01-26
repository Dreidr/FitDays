import 'dart:math';
import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';

class WorkoutGenerator {
  static final _rng = Random();

  static int exerciseCountForDuration(int minutes) {
    if (minutes <= 30) return 6;
    if (minutes <= 40) return 8;
    if (minutes <= 50) return 10;
    return 12;
  }

  static String _laneFromProfile(UserProfile? profile) {
    final plan = (profile?.workoutPlan ?? "").trim();
    if (plan == "Cardio") return "cardio";
    if (plan == "Flexibility Training") return "stretching";
    if (plan == "Stability Training") return "stretching"; // MVP fallback
    return "strength";
  }

  static bool _isStrengthyCategory(String c) {
    final x = c.toLowerCase().trim();
    if (x.isEmpty) return true;

    // treat these as "strength lane"
    return x != "cardio" && x != "stretching";
  }

  static bool _matchesFocus(String focusTitle, Map<String, dynamic> ex) {
    final body = (ex["bodyPart"] ?? "").toString().toLowerCase();
    final name = (ex["name"] ?? "").toString().toLowerCase();
    final target = (ex["target"] ?? "").toString().toLowerCase();

    bool hasAny(List<String> words) =>
        words.any((w) => body.contains(w) || name.contains(w) || target.contains(w));

    if (focusTitle.toLowerCase().contains("upper")) {
      return hasAny(["chest", "back", "shoulder", "biceps", "triceps", "forearm", "lats"]);
    }
    if (focusTitle.toLowerCase().contains("lower")) {
      return hasAny(["quadriceps", "hamstring", "glute", "calves", "adductor"]);
    }
    if (focusTitle.toLowerCase().contains("full")) {
      return true; // allow anything
    }

    // cardio/stretch titles can just return true
    return true;
  }

  static List<Map<String, dynamic>> _pickRandomUnique(
    List<Map<String, dynamic>> pool,
    int count,
  ) {
    if (pool.isEmpty) return const [];
    final copy = [...pool]..shuffle(_rng);
    return copy.take(min(count, copy.length)).toList();
  }

  static Future<List<PlannedExercise>> generatePlannedExercises({
    required UserProfile? profile,
    required DayPlan plan,
  }) async {
    final all = await LocalExerciseRepo.loadAll();

    final lane = _laneFromProfile(profile);
    final duration = profile?.workoutDuration ?? 40;
    final n = exerciseCountForDuration(duration);

    // 1) Filter by lane (category)
    List<Map<String, dynamic>> lanePool;
    if (lane == "cardio") {
      lanePool = all.where((e) => (e["category"] ?? "").toString().toLowerCase() == "cardio").toList();
    } else if (lane == "stretching") {
      lanePool = all.where((e) => (e["category"] ?? "").toString().toLowerCase() == "stretching").toList();
    } else {
      lanePool = all.where((e) => _isStrengthyCategory((e["category"] ?? "").toString())).toList();
    }

    // 2) For strength lane, also filter by focus title (Upper/Lower/Full)
    final focusedPool = lane == "strength"
        ? lanePool.where((e) => _matchesFocus(plan.title, e)).toList()
        : lanePool;

    // 3) Pick N
    final picked = _pickRandomUnique(focusedPool.isNotEmpty ? focusedPool : lanePool, n);

    // 4) Convert to PlannedExercise (MVP prescription)
    // Later you’ll modify reps/sets by goal + level.
    return picked.map((e) {
      final id = (e["id"] ?? "").toString();
      return PlannedExercise(
        exerciseId: id,
        sets: (lane == "strength") ? 3 : 1,
        reps: (lane == "strength") ? 12 : 1,
        weightKg: 0,
      );
    }).toList();
  }
}
