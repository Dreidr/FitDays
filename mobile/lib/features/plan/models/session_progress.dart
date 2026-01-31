class SessionItem {
  final String dayLabel;     // "Tue"
  final String title;        // "Upper Body"
  final int minutes;         // 50
  final bool completed;      // true/false

  const SessionItem({
    required this.dayLabel,
    required this.title,
    required this.minutes,
    required this.completed,
  });
}

class WeekProgress {
  final int weekNumber; // 1, 2...
  final List<SessionItem> sessions;

  const WeekProgress({
    required this.weekNumber,
    required this.sessions,
  });
}
