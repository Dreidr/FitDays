import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    required this.dates,
    required this.completedDates,
    required this.workoutDays,
  });

  final List<DateTime> dates;
  final Set<DateTime> completedDates;
  final Set<int> workoutDays;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final week1 = dates.take(7).toList();
    final week2 = dates.skip(7).take(7).toList();
    const _weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: week1.map((date) => _DayCell(date)).toList(),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: week2.map((date) => _DayCell(date)).toList(),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final label = _weekdayLabels[i]; // ["Mon"...]
            return SizedBox(
              width: 36, // match your day cell width
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _DayCell(DateTime date) {
    final today = DateTime.now();
    final isToday = _isSameDay(date, today);
    final isCompleted = completedDates.any((d) => _isSameDay(d, date));
    final isWorkoutDay = workoutDays.contains(date.weekday);

    Color bg;
    Color text;

    if (isCompleted) {
      bg = const Color(0xFF4442D9);
      text = Colors.white;
    } else if (isToday && isWorkoutDay) {
      bg = const Color(0xFF4442D9).withOpacity(0.15);
      text = const Color(0xFF4442D9);
    } else {
      bg = Colors.transparent;
      text = Colors.black54;
    }

    return Column(
  children: [
    const SizedBox(height: 6),

    Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ),

        // dumbbell marker (only on workout days)
        if (isWorkoutDay)
          Positioned(
            right: 4,
            bottom: 4,
            child: Icon(
              Icons.fitness_center,
              size: 12,
              color: isCompleted
                  ? Colors.white
                  : const Color(0xFF4442D9),
            ),
          ),
      ],
    ),

    // 👇 TODAY DOT
    if (isToday) ...[
      const SizedBox(height: 4),
      Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF4442D9),
        ),
      ),
    ],
  ],
);

  }
}
