import '/core/enums/workout_type.dart';

class DayPlan {
  final DateTime date;
  final bool isWorkoutDay;

  final WorkoutType type;

  final String title;
  final String subtitle;

  DayPlan({
    required this.date,
    required this.isWorkoutDay,
    required this.type,
    required this.title,
    required this.subtitle,
  });
}