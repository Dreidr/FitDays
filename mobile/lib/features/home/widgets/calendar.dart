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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final week1 = dates.take(7).toList();
    const weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: week1.map((date) => _dayCell(date)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final label = weekdayLabels[i];
            return SizedBox(
              width: 40,
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

  Widget _dayCell(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final day = _dateOnly(date);

    final isToday = _isSameDay(day, today);
    final isCompleted = completedDates.any(
      (d) => _isSameDay(_dateOnly(d), day),
    );
    final isWorkoutDay = workoutDays.contains(day.weekday);
    final isPast = day.isBefore(today);
    final isMissed = isWorkoutDay && isPast && !isCompleted;
    final isPlanned = isWorkoutDay && !isCompleted && !isMissed;

    Color fillColor = Colors.transparent;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black54;

    if (isCompleted) {
      fillColor = Colors.white;
      borderColor = Colors.white;
      textColor = const Color(0xFF2ECC71);
    } else if (isMissed) {
      fillColor = const Color(0xFFF7F4F4);
      borderColor = const Color(0xFFE0CFCF);
      textColor = Colors.black45;
    } else if (isPlanned) {
      fillColor = Colors.transparent;
      borderColor = const Color(0xFF4442D9);
      textColor = const Color(0xFF4442D9);
    }

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          const SizedBox(height: 6),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: fillColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: (isCompleted || isMissed || isPlanned) ? 1.6 : 0,
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, size: 18, color: Color(0xFF2ECC71))
                    : Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
              ),
            ],
          ),

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
          ] else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}
