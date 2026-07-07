import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/services/plan_calendar_service.dart';
import 'package:mobile/core/enums/workout_type.dart';

class DayPlanBuilder {
  static List<DayPlan> buildNext3Plans({
    required DateTime startDate,
    required List<String> workoutDays,
    required int durationMinutes,
    required UserProfile? profile,
  }) {
    final today = PlanCalendarService.dateOnly(DateTime.now());

    return [
      _buildDay(
        date: today,
        startDate: startDate,
        workoutDays: workoutDays,
        durationMinutes: durationMinutes,
        profile: profile,
      ),
      _buildDay(
        date: today.add(const Duration(days: 1)),
        startDate: startDate,
        workoutDays: workoutDays,
        durationMinutes: durationMinutes,
        profile: profile,
      ),
      _buildDay(
        date: today.add(const Duration(days: 2)),
        startDate: startDate,
        workoutDays: workoutDays,
        durationMinutes: durationMinutes,
        profile: profile,
      ),
    ];
  }

 static WorkoutType workoutTypeFromTitle(String title) {
  switch (title.toLowerCase()) {
    case "push":
      return WorkoutType.push;

    case "pull":
      return WorkoutType.pull;

    case "legs":
      return WorkoutType.legs;

    case "upper body":
      return WorkoutType.upperBody;

    case "lower body":
      return WorkoutType.lowerBody;

    case "full body":
    case "full body starter":
      return WorkoutType.fullBody;

    case "hiit":
      return WorkoutType.hiit;

    case "steady cardio":
      return WorkoutType.steadyCardio;

    case "core & conditioning":
      return WorkoutType.coreConditioning;

    case "full body circuit":
      return WorkoutType.fullBodyCircuit;

    case "stretching":
      return WorkoutType.stretching;

    case "mobility":
      return WorkoutType.mobility;

    case "recovery":
      return WorkoutType.recovery;

    case "yoga flow":
      return WorkoutType.yogaFlow;

    case "balance training":
      return WorkoutType.balanceTraining;

    case "functional movement":
      return WorkoutType.functionalMovement;

    case "mobility & stability":
      return WorkoutType.mobilityStability;

    default:
      return WorkoutType.fullBody;
  }
}

  static List<DayPlan> buildWeek({
    required DateTime startDate,
    required List<String> workoutDays,
    required int durationMinutes,
    required UserProfile? profile,
  }) {
    final today = PlanCalendarService.dateOnly(DateTime.now());

    final weekStart = PlanCalendarService.mondayOfWeek(today);

    return List.generate(
      7,
      (index) => _buildDay(
        date: weekStart.add(Duration(days: index)),
        startDate: startDate,
        workoutDays: workoutDays,
        durationMinutes: durationMinutes,
        profile: profile,
      ),
    );
  }

  static List<String> _splitForPlan(UserProfile? profile) {
    final plan = profile?.workoutPlan?.trim().toLowerCase();

    switch (plan) {
      case 'strength training':
        final days = profile?.workoutDays.length ?? 3;

        if (days <= 3) {
          return ['Push', 'Pull', 'Legs'];
        }

        if (days == 4) {
          return ['Upper Body', 'Lower Body'];
        }

        if (days == 5) {
          return ['Push', 'Pull', 'Legs', 'Upper Body', 'Lower Body'];
        }

        return [
          'Push',
          'Pull',
          'Legs',
          'Upper Body',
          'Lower Body',
          'Full Body',
        ];

      case 'cardio':
        return [
          'HIIT',
          'Steady Cardio',
          'Core & Conditioning',
          'Full Body Circuit',
        ];

      case 'flexibility training':
        return ['Stretching', 'Mobility', 'Recovery', 'Yoga Flow'];

      case 'stability training':
        return [
          'Core Stability',
          'Balance Training',
          'Functional Movement',
          'Mobility & Stability',
        ];

      default:
        return ['Full Body'];
    }
  }

  static DayPlan _buildDay({
    required DateTime date,
    required DateTime startDate,
    required List<String> workoutDays,
    required int durationMinutes,
    required UserProfile? profile,
  }) {
    final daysSet = workoutDays.map(_normalizeDay).toSet();

    final split = _splitForPlan(profile);
    int workoutCountUpTo(DateTime target) {
      int count = 0;
      DateTime d = PlanCalendarService.dateOnly(startDate);

      while (!d.isAfter(target)) {
        if (daysSet.contains(_weekdayShort(d))) {
          count++;
        }

        d = d.add(const Duration(days: 1));
      }

      return count;
    }

    final d = PlanCalendarService.dateOnly(date);
    final weekday = _weekdayShort(d);

    final isWorkoutDay = daysSet.contains(weekday);

    if (!isWorkoutDay) {
      return DayPlan(
        date: d,
        isWorkoutDay: false,
        type: WorkoutType.rest,
        title: "Rest Day",
        subtitle: "Take it easy today",
      );
    }

    final wc = workoutCountUpTo(d);
    final idx = (wc - 1) % split.length;

    return DayPlan(
  date: d,
  isWorkoutDay: true,
  type: workoutTypeFromTitle(split[idx]),
  title: split[idx],
  subtitle: "$durationMinutes min • ${_planLabel(profile)}",
);
  }

  static String _normalizeDay(String s) {
    final x = s.trim().toLowerCase();

    if (x.startsWith("mon")) return "Mon";
    if (x.startsWith("tue")) return "Tue";
    if (x.startsWith("wed")) return "Wed";
    if (x.startsWith("thu")) return "Thu";
    if (x.startsWith("fri")) return "Fri";
    if (x.startsWith("sat")) return "Sat";
    if (x.startsWith("sun")) return "Sun";

    return s.trim();
  }

  static String _weekdayShort(DateTime date) {
    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return labels[date.weekday - 1];
  }

  static String _planLabel(UserProfile? profile) {
    final p = profile?.workoutPlan?.trim();
    return (p != null && p.isNotEmpty) ? p : "Workout";
  }
}
