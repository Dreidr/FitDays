  import 'dart:math';
  import 'package:mobile/core/models/user_profile.dart';
  import 'package:mobile/features/workout/models/day_plan.dart';
  import 'package:mobile/features/workout/models/planned_exercise.dart';
  import 'package:mobile/features/workout/services/local_exercise_repo.dart';

  class WorkoutGenerator {
    
    static final _rng = Random();

    static int exerciseCountForDuration(int minutes) {
      if (minutes <= 30) return 5;
      if (minutes <= 40) return 6;
      if (minutes <= 50) return 8;
      return 12;
    }
    

    // ---------- helpers: normalize ----------
    static String _norm(String? s) => (s ?? "").trim().toLowerCase();

    static String _laneFromProfile(UserProfile? profile) {
      final p = _norm(profile?.workoutPlan);

      if (p.contains("cardio")) return "cardio";
      if (p.contains("flex")) return "stretching";
      if (p.contains("stabil")) return "stretching"; // MVP fallback

      return "strength";
    }

    static String _userLevel(UserProfile? p) {
      final x = _norm(p?.fitnessLevel);
      if (x.contains("begin")) return "beginner";
      if (x.contains("inter")) return "intermediate";
      if (x.contains("adv")) return "advanced";
      return "intermediate";
    }

    static String _userGoal(UserProfile? p) {
      final x = _norm(p?.fitnessGoal);
      if (x.contains("strength")) return "strength";
      if (x.contains("muscle") || x.contains("hypertrophy")) return "hypertrophy";
      if (x.contains("lose") || x.contains("fat") || x.contains("cut")) return "fatloss";
      return "general";
    }

    // ---------- difficulty gating (exercise level vs user level) ----------
    static int _levelRank(String s) {
      final x = _norm(s);
      if (x.contains("begin")) return 1;
      if (x.contains("inter")) return 2;
      if (x.contains("adv")) return 3;
      return 2;
    }

    static bool _allowedByLevel(UserProfile? p, Map<String, dynamic> e) {
      final exRank = _levelRank((e["level"] ?? "").toString());
      final userRank = _levelRank(p?.fitnessLevel ?? "");

      if (exRank <= userRank) return true;
      if (exRank == userRank + 1) return _rng.nextDouble() < 0.25; // 25% chance
      return false;
    }

    // ---------- strength prescription (sets + rep range) ----------
    static ({int sets, int repsMin, int repsMax}) _strengthRx(UserProfile? p) {
      final lvl = _userLevel(p);
      final goal = _userGoal(p);

      if (goal == "strength") {
        return switch (lvl) {
          "beginner" => (sets: 3, repsMin: 5, repsMax: 6),
          "intermediate" => (sets: 4, repsMin: 4, repsMax: 6),
          _ => (sets: 5, repsMin: 3, repsMax: 5),
        };
      }

      if (goal == "hypertrophy") {
        return switch (lvl) {
          "beginner" => (sets: 3, repsMin: 8, repsMax: 12),
          "intermediate" => (sets: 4, repsMin: 8, repsMax: 12),
          _ => (sets: 5, repsMin: 6, repsMax: 12),
        };
      }

      // fatloss / general
      return switch (lvl) {
        "beginner" => (sets: 3, repsMin: 12, repsMax: 15),
        "intermediate" => (sets: 3, repsMin: 10, repsMax: 15),
        _ => (sets: 4, repsMin: 10, repsMax: 15),
      };
    }

    static int _randInt(int a, int b) => a + _rng.nextInt((b - a) + 1);

    static int _tweakSetsForDuration(int sets, int duration) {
      if (duration <= 30) return max(2, sets - 1);
      if (duration >= 55) return min(5, sets + 1);
      return sets;
    }

    // ---------- strength: compound vs accessory ----------
    static bool _looksCompound(Map<String, dynamic> e) {
      final name = _norm(e["name"]?.toString());
      final target = _norm(e["target"]?.toString());

      return name.contains("squat") ||
          name.contains("deadlift") ||
          name.contains("bench") ||
          name.contains("row") ||
          name.contains("press") ||
          target.contains("quadriceps") ||
          target.contains("glutes") ||
          target.contains("back") ||
          target.contains("chest");
    }

    static int _setsForExercise(int baseSets, Map<String, dynamic> e) {
      final s = _looksCompound(e) ? baseSets : max(2, baseSets - 1);
      return min(5, s);
    }

    // ---------- equipment + weight suggestion ----------
    static String _equip(Map<String, dynamic> e) => _norm(e["equipment"]?.toString());

    static bool _isBodyweightLike(Map<String, dynamic> e) {
      final eq = _equip(e);
      final cat = _norm(e["category"]?.toString());

      if (eq.contains("body")) return true;
      if (cat == "cardio" || cat == "stretching") return true;

      final name = _norm(e["name"]?.toString());
      return name.contains("push up") ||
          name.contains("pull up") ||
          name.contains("plank") ||
          name.contains("burpee") ||
          name.contains("jump");
    }

    static bool _canSuggestWeight(Map<String, dynamic> e) {
      final eq = _equip(e);

      // safe to suggest for these:
      if (eq.contains("dumbbell") ||
          eq.contains("kettlebell") ||
          eq.contains("cable") ||
          eq.contains("machine")) {
        return true;
      }

      // barbell/other: user sets it
      return false;
    }

    static double? _suggestWeightKg(UserProfile? p, Map<String, dynamic> e) {
      if (!_canSuggestWeight(e)) return null;

      final bw = p?.weightKg;
      if (bw == null || bw <= 0) return null;

      final goal = _userGoal(p);
      final lvl = _userLevel(p);

      // conservative baseline % of bodyweight
      double pct = 0.06;
      if (goal == "strength") pct = 0.08;
      if (goal == "hypertrophy") pct = 0.07;
      if (goal == "fatloss") pct = 0.05;

      if (lvl == "beginner") pct *= 0.8;
      if (lvl == "advanced") pct *= 1.2;

      final body = _norm(e["bodyPart"]?.toString());
      final isLower = body.contains("quad") ||
          body.contains("hamstring") ||
          body.contains("glute") ||
          body.contains("calves");

      if (isLower) pct *= 1.4;

      final raw = bw * pct;

      // round to nearest 0.5kg
      return (raw * 2).round() / 2.0;
    }

    // ---------- existing helpers ----------
    static bool _isStrengthyCategory(String c) {
      final x = _norm(c);
      if (x.isEmpty) return true;
      return x != "cardio" && x != "stretching";
    }

    static bool _matchesFocus(String focusTitle, Map<String, dynamic> ex) {
      final title = _norm(focusTitle);
      final body = _norm(ex["bodyPart"]?.toString());
      final name = _norm(ex["name"]?.toString());
      final target = _norm(ex["target"]?.toString());

      bool hasAny(List<String> words) =>
          words.any((w) => body.contains(w) || name.contains(w) || target.contains(w));

      if (title.contains("upper")) {
        return hasAny(["chest", "back", "shoulder", "biceps", "triceps", "forearm", "lats"]);
      }
      if (title.contains("lower")) {
        return hasAny(["quadriceps", "hamstring", "glute", "calves", "adductor"]);
      }
      if (title.contains("full")) return true;

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

    // ---------- main ----------
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
        lanePool = all.where((e) => _norm(e["category"]?.toString()) == "cardio").toList();
      } else if (lane == "stretching") {
        lanePool = all.where((e) => _norm(e["category"]?.toString()) == "stretching").toList();
      } else {
        lanePool = all.where((e) => _isStrengthyCategory((e["category"] ?? "").toString())).toList();
      }

      // 2) Focus filter (strength only)
      final focusedPool = lane == "strength"
          ? lanePool.where((e) => _matchesFocus(plan.title, e)).toList()
          : lanePool;

      // 3) Level filter (use your dataset "level")
      final basePool = (focusedPool.isNotEmpty ? focusedPool : lanePool)
          .where((e) => _allowedByLevel(profile, e))
          .toList();

      final pool = basePool.isNotEmpty ? basePool : (focusedPool.isNotEmpty ? focusedPool : lanePool);

      // 4) Pick N
      final picked = _pickRandomUnique(pool, n);

      // 5) Convert to PlannedExercise
      if (lane != "strength") {
        // Cardio/stretching MVP: keep it simple and safe
        return picked.map((e) {
          final id = (e["id"] ?? "").toString();
          return PlannedExercise(
            exerciseId: id,
            sets: 1,
            reps: 1,
            weightKg: null,
          );
        }).toList();
      }

      // Strength lane
      final rx = _strengthRx(profile);
      final baseSets = _tweakSetsForDuration(rx.sets, duration);

      return picked.map((e) {
        final id = (e["id"] ?? "").toString();
        final reps = _randInt(rx.repsMin, rx.repsMax);
        final sets = _setsForExercise(baseSets, e);

        final weight = _isBodyweightLike(e) ? null : _suggestWeightKg(profile, e);

        return PlannedExercise(
          exerciseId: id,
          sets: sets,
          reps: reps,
          weightKg: weight,
        );
      }).toList();
    }
  }

