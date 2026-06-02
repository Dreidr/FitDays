import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_history.dart';

class WorkoutHistoryService {
  static const String _key = 'workout_history';

  static Future<void> saveWorkout(
    WorkoutHistory workout,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getStringList(_key) ?? [];

    existing.add(
      jsonEncode(workout.toJson()),
    );

    await prefs.setStringList(
      _key,
      existing,
    );
  }

  static Future<List<WorkoutHistory>>
  getWorkoutHistory() async {
    final prefs =
        await SharedPreferences.getInstance();

    final stored =
        prefs.getStringList(_key) ?? [];

    return stored
        .map(
          (item) => WorkoutHistory.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}