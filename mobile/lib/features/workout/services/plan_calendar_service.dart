import 'package:flutter/material.dart';

class PlanCalendarService {
  static String dayLabel(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final d = DateUtils.dateOnly(date);

    if (d == today) return "Today";
    if (d == today.add(const Duration(days: 1))) return "Tomorrow";

    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return labels[d.weekday - 1];
  }

  static DateTime dateOnly(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime addDays(DateTime d, int days) {
    return DateTime(d.year, d.month, d.day + days);
  }

  static DateTime mondayOfWeek(DateTime d) {
    final x = dateOnly(d);
    return addDays(x, -(x.weekday - DateTime.monday));
  }

  static Set<int> mapToWeekdays(List<String> days) {
    const map = {
      "Mon": DateTime.monday,
      "Tue": DateTime.tuesday,
      "Wed": DateTime.wednesday,
      "Thu": DateTime.thursday,
      "Fri": DateTime.friday,
      "Sat": DateTime.saturday,
      "Sun": DateTime.sunday,
    };

    return days.map((d) => map[d]).whereType<int>().toSet();
  }

  static int getWeekNumber(DateTime startDate) {
    final today = dateOnly(DateTime.now());
    final startMonday = mondayOfWeek(startDate);

    final days = today.difference(startMonday).inDays;
    final safeDays = days < 0 ? 0 : days;

    return (safeDays ~/ 7) + 1;
  }

  static List<DateTime> getPlanWeekDates(DateTime startDate) {
    final start = dateOnly(startDate);
    final today = dateOnly(DateTime.now());

    final weekIndex = today.difference(start).inDays ~/ 7;

    final rawWeekStart = addDays(start, weekIndex * 7);

    final weekStart = mondayOfWeek(rawWeekStart);

    return List.generate(
      7,
      (i) => addDays(weekStart, i),
    );
  }
}