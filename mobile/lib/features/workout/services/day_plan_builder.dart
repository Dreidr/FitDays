import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/services/plan_calendar_service.dart';

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

  static DayPlan _buildDay({
    required DateTime date,
    required DateTime startDate,
    required List<String> workoutDays,
    required int durationMinutes,
    required UserProfile? profile,
  }) {
    final daysSet = workoutDays.map(_normalizeDay).toSet();

    const split = [
      "Upper Body",
      "Lower Body",
      "Full Body",
    ];

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
        title: "Rest Day",
        subtitle: "Recovery • optional walk/stretch",
      );
    }

    final wc = workoutCountUpTo(d);
    final idx = (wc - 1) % split.length;

    return DayPlan(
      date: d,
      isWorkoutDay: true,
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
    const labels = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    return labels[date.weekday - 1];
  }

  static String _planLabel(UserProfile? profile) {
    final p = profile?.workoutPlan?.trim();
    return (p != null && p.isNotEmpty) ? p : "Workout";
  }
}