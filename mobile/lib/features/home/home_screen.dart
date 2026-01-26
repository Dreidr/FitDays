import 'package:flutter/material.dart';
import 'package:mobile/features/home/widgets/top_row.dart';
import 'package:mobile/features/home/widgets/greeting.dart';
import 'package:mobile/features/home/widgets/calendar.dart';
import 'package:mobile/features/home/widgets/workout_carousel.dart';
import 'package:mobile/features/home/widgets/quick_actions.dart';
import 'package:mobile/features/home/widgets/insights.dart';
import 'package:mobile/app/theme/app_decorations.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/workout_detail_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/onboarding/profile_setup_screen.dart';
import 'package:mobile/core/widgets/complete_setup_banner.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/features/workout/services/workout_generator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userNameVN,
    required this.workoutStreak,
    required this.startDate,
    required this.workoutDays,
  });

  final ValueNotifier<String> userNameVN;
  final int workoutStreak;
  final DateTime startDate;
  final List<String> workoutDays;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PlannedExercise> _placeholderPlanFor(String title) {
    // Later: build from ExerciseDB based on title + duration + fitnessLevel
    if (title.contains("Upper")) {
      return const [
        PlannedExercise(exerciseId: "0041", sets: 3, reps: 12, weightKg: 20),
        PlannedExercise(exerciseId: "0380", sets: 3, reps: 12, weightKg: 20),
      ];
    }

    if (title.contains("Lower")) {
      return const [
        PlannedExercise(exerciseId: "1308", sets: 3, reps: 10, weightKg: 22.5),
        PlannedExercise(exerciseId: "1410", sets: 3, reps: 12, weightKg: 20),
      ];
    }

    return const [
      PlannedExercise(exerciseId: "0041", sets: 3, reps: 12, weightKg: 20),
      PlannedExercise(exerciseId: "1308", sets: 3, reps: 10, weightKg: 22.5),
    ];
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return "Today";
    if (d == today.add(const Duration(days: 1))) return "Tomorrow";

    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return labels[d.weekday - 1];
  }

  String _totalTimeTextFor(DayPlan plan, int durationMinutes) {
    return plan.isWorkoutDay ? "$durationMinutes mins" : "Rest day";
  }

  final Set<DateTime> completedDates = {}; // ✅ now valid

  int getWeekNumber() {
    final days = DateTime.now().difference(widget.startDate).inDays;
    return (days ~/ 7) + 1;
  }

  Set<int> _mapToWeekdays(List<String> days) {
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

  String _planLabel(UserProfile? profile) {
    final p = profile?.workoutPlan?.trim();
    return (p != null && p.isNotEmpty) ? p : "Workout";
  }

  List<DateTime> getTwoWeekDates() {
    final today = DateTime.now();
    final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    return List.generate(14, (i) => startOfLastWeek.add(Duration(days: i)));
  }

  List<DayPlan> buildNextWorkoutPlans({
    required Set<int> workoutWeekdays,
    required int durationMinutes,
    required UserProfile? profile,
    int count = 3,
  }) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    // Simple split for MVP
    const split = ["Upper Body", "Lower Body", "Full Body"];
    var splitIndex = 0;

    final result = <DayPlan>[];

    for (int i = 0; i < 21 && result.length < count; i++) {
      final date = start.add(Duration(days: i));
      if (!workoutWeekdays.contains(date.weekday)) continue;

      final title = split[splitIndex % split.length];
      splitIndex++;

      result.add(
        DayPlan(
          date: date,
          isWorkoutDay: true,
          title: title,
          subtitle: "$durationMinutes min • ${_planLabel(profile)}",
        ),
      );
    }

    return result.isEmpty ? [_defaultPlan()] : result;
  }

  bool get _profileCompleted => LocalStorageService.isProfileComplete;

  Future<void> _goToSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
    if (!mounted) return;
    setState(() {}); // ✅ refresh carousel after completing setup
  }

  DayPlan _defaultPlan() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    return DayPlan(
      date: start,
      isWorkoutDay: true,
      title: "Full Body Starter",
      subtitle: "30–40 min • Beginner friendly",
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = LocalStorageService.getUserProfile();
    final completed = _profileCompleted;

    final duration = profile?.workoutDuration ?? 40;
    final savedDays = profile?.workoutDays ?? widget.workoutDays;
    final workoutWeekdays = _mapToWeekdays(savedDays);

    final plans = completed
        ? buildNextWorkoutPlans(
            workoutWeekdays: workoutWeekdays,
            durationMinutes: duration,
            profile: profile,
            count: 3,
          )
        : [_defaultPlan()];

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
                    Greeting(userNameVN: widget.userNameVN),
                    const SizedBox(height: 12),
                    Calendar(
                      dates: getTwoWeekDates(),
                      completedDates: completedDates,
                      workoutDays: workoutWeekdays,
                    ),
                    const SizedBox(height: 20),
                    WorkoutCarousel(
                      plans: plans,
                      onPlanTap: (plan) async {
                        final profile = LocalStorageService.getUserProfile();
                        final generated =
                            await WorkoutGenerator.generatePlannedExercises(
                              profile: profile,
                              plan: plan,
                            );

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailScreen(
                              dayLabel: _dayLabel(plan.date),
                              title: plan.title,
                              totalTimeText: _totalTimeTextFor(plan, duration),
                              plan: generated,
                            ),
                          ),
                        );
                      },

                      // ✅ For skippers only: 2nd swipe = complete setup banner
                      extraCard: completed
                          ? null
                          : SizedBox(
                              height: 190,
                              child: CompleteSetupBanner(
                                onCompletePressed: _goToSetup,
                              ),
                            ),
                      onExtraTap: completed ? null : _goToSetup,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              QuickActions(),
              const SizedBox(height: 18),

              InsightsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
