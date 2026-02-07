// mobile/features/workout/models/saved_workout.dart
import 'dart:convert';
import 'planned_exercise.dart';

class SavedWorkout {
  final String id; // unique
  final DateTime createdAt;

  final String title; // DayPlan title e.g. "Upper Body"
  final int durationMinutes;
  final bool warmupOn;

  final List<PlannedExercise> exercises;

  const SavedWorkout({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.durationMinutes,
    required this.warmupOn,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt.toIso8601String(),
        "title": title,
        "durationMinutes": durationMinutes,
        "warmupOn": warmupOn,
        "exercises": exercises.map((e) => e.toJson()).toList(),
      };

  factory SavedWorkout.fromJson(Map<String, dynamic> json) => SavedWorkout(
        id: (json["id"] ?? "").toString(),
        createdAt: DateTime.parse(json["createdAt"]),
        title: (json["title"] ?? "").toString(),
        durationMinutes: (json["durationMinutes"] as num).toInt(),
        warmupOn: json["warmupOn"] == true,
        exercises: (json["exercises"] as List)
            .map((e) => PlannedExercise.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  String toRawJson() => jsonEncode(toJson());
  factory SavedWorkout.fromRawJson(String raw) =>
      SavedWorkout.fromJson(jsonDecode(raw));
}
