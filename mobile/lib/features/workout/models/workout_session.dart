import 'package:mobile/features/workout/models/session_type.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';

class WorkoutSession {
  final String id; // e.g. "2026-01-26_strength_upper"
  final DateTime date;
  final SessionType type;
  final String title;
  final int durationMinutes;

  final bool warmupOn;

  // For now, we keep it simple and reuse your existing PlannedExercise list.
  // Later cardio/stretch can become “blocks”, but MVP can still list items.
  final List<PlannedExercise> items;

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.durationMinutes,
    required this.warmupOn,
    required this.items,
  });
}
