import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/top_row.dart';
import 'package:mobile/core/widgets/greeting.dart';
import 'package:mobile/core/widgets/calendar.dart';
import 'package:mobile/core/widgets/workout_card_carousel.dart';
import 'package:mobile/core/widgets/quick_actions.dart';
import 'package:mobile/core/widgets/insights.dart';
import 'package:mobile/core/widgets/bottom_navigation.dart';
import 'package:mobile/core/theme/app_decorations.dart';
import 'package:mobile/core/models/day_plan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userName,
    required this.workoutStreak,
    required this.startDate,
    required this.workoutDays,
  });

  final String userName;
  final int workoutStreak;
  final DateTime startDate;
  final List<String> workoutDays;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<DateTime> completedDates = {}; // ✅ now valid

  int getWeekNumber() {
    final days = DateTime.now().difference(widget.startDate).inDays;
    return (days ~/ 7) + 1;
  }

  Set<int> getWorkoutWeekdays() {
    const map = {
      "Mon": DateTime.monday,
      "Tue": DateTime.tuesday,
      "Wed": DateTime.wednesday,
      "Thu": DateTime.thursday,
      "Fri": DateTime.friday,
      "Sat": DateTime.saturday,
      "Sun": DateTime.sunday,
    };

    return widget.workoutDays.map((d) => map[d]).whereType<int>().toSet();
  }

  List<DateTime> getTwoWeekDates() {
    final today = DateTime.now();
    final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    return List.generate(14, (i) => startOfLastWeek.add(Duration(days: i)));
  }

  List<DayPlan> buildThreeDayPlans(Set<int> workoutWeekdays) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    const workoutTypes = [
      ("Upper Body", "45 min • Strength"),
      ("Lower Body", "40 min • Strength"),
      ("Full Body", "35 min • Conditioning"),
    ];

    var workoutIndex = 0;

    return List.generate(3, (i) {
      final date = start.add(Duration(days: i));
      final isWorkoutDay = workoutWeekdays.contains(date.weekday);

      if (!isWorkoutDay) {
        return DayPlan(
          date: date,
          isWorkoutDay: false,
          title: "Recovery day",
          subtitle: "Stretch • Walk • Mobility",
        );
      }

      final wt = workoutTypes[workoutIndex % workoutTypes.length];
      workoutIndex++;

      return DayPlan(
        date: date,
        isWorkoutDay: true,
        title: wt.$1,
        subtitle: wt.$2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutWeekdays = getWorkoutWeekdays();
    final plans = buildThreeDayPlans(workoutWeekdays);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeTopRow(
                streak: widget.workoutStreak,
                week: getWeekNumber(),
                onStreakTap: () {
                  // TODO: open streak details screen later
                },
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(context),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Greeting(userName: widget.userName),
                    const SizedBox(height: 12),
                    Calendar(
                      dates: getTwoWeekDates(),
                      completedDates: completedDates,
                      workoutDays: getWorkoutWeekdays(),
                    ),
                    const SizedBox(height: 20),
                    WorkoutCarousel(
                      plans: buildThreeDayPlans(getWorkoutWeekdays()),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              QuickActions(),
              const SizedBox(height: 24),

              InsightsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(),
    );
  }
}
