import 'package:flutter/material.dart';
import 'package:mobile/features/home/widgets/top_row.dart';
import 'package:mobile/features/home/widgets/greeting.dart';
import 'package:mobile/features/home/widgets/calendar.dart';
import 'package:mobile/features/home/widgets/workout_carousel.dart';
import 'package:mobile/features/home/widgets/quick_actions.dart';
import 'package:mobile/app/theme/app_decorations.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/workout_detail_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/onboarding/profile_setup_screen.dart';
import 'package:mobile/core/widgets/complete_setup_banner.dart';
import 'package:mobile/features/workout/services/workout_generator.dart';
import 'package:mobile/features/workout/models/saved_workout.dart';
import 'package:mobile/features/workout/services/play_state.dart';
import 'package:mobile/features/workout/services/plan_calendar_service.dart';
import 'package:mobile/features/workout/services/workout_completion_service.dart';
import 'package:mobile/features/workout/services/day_plan_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userNameVN,
    required this.workoutStreak,
    required this.startDate,
    required this.workoutDays,
    this.warmupCount = 0, // ✅ optional default
  });

  final ValueNotifier<String> userNameVN;
  final int workoutStreak;
  final DateTime startDate;
  final List<String> workoutDays;
  final int warmupCount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _totalTimeTextFor(DayPlan plan, int durationMinutes) {
    return plan.isWorkoutDay ? "$durationMinutes mins" : "Rest day";
  }

  bool get _profileCompleted => LocalStorageService.isProfileComplete;

  Future<void> _goToSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(allowSkip: false),
      ),
    );

    setState(() {});
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
    final workoutWeekdays = PlanCalendarService.mapToWeekdays(savedDays);

    final plans = completed
        ? DayPlanBuilder.buildNext3Plans(
            startDate: profile?.startDate ?? widget.startDate,
            workoutDays: savedDays,
            durationMinutes: duration,
            profile: profile,
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
                week: PlanCalendarService.getWeekNumber(
                  profile?.startDate ?? widget.startDate,
                ),
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

                    Divider(
                      thickness: 1,
                      color: Colors.grey.withValues(alpha: 0.25),
                    ),

                    Calendar(
                      dates: PlanCalendarService.getPlanWeekDates(
                        profile?.startDate ?? widget.startDate,
                      ),
                      completedDates:
                          WorkoutCompletionService.getCompletedDates(),
                      workoutDays: workoutWeekdays,
                    ),
                    const SizedBox(height: 20),
                    WorkoutCarousel(
                      plans: plans,
                      workoutForPlan: (plan) {
                        final id = PlayStateResolver.workoutIdFor(
                          plan.date,
                          plan,
                        );

                        return LocalStorageService.getSavedWorkoutById(id);
                      },

                      onPlanTap: (plan) async {
                        // Rest day: don’t generate, just inform (or navigate to a RestDay screen later)
                        if (!plan.isWorkoutDay) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Rest day 😴")),
                          );
                          return;
                        }

                        final profile = LocalStorageService.getUserProfile();
                        final durationMinutes = profile?.workoutDuration ?? 40;

                        // ✅ deterministic id (same used by Play shortcut)
                        final id = PlayStateResolver.workoutIdFor(
                          plan.date,
                          plan,
                        );

                        // ✅ only generate if not saved yet
                        final existing =
                            LocalStorageService.getSavedWorkoutById(id);

                        if (existing == null || existing.exercises.isEmpty) {
                          final generated =
                              await WorkoutGenerator.generatePlannedExercises(
                                profile: profile,
                                plan: plan,
                              );

                          final saved = SavedWorkout(
                            id: id,
                            createdAt: DateTime.now(),
                            title: plan.title,
                            durationMinutes: durationMinutes,
                            warmupOn: true,
                            exercises: generated,
                          );

                          await LocalStorageService.saveGeneratedWorkout(saved);
                        }

                        if (!context.mounted) return;

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailScreen(
                              plan: plan,
                              dayLabel: PlanCalendarService.dayLabel(plan.date),
                              title: plan.title,
                              totalTimeText: _totalTimeTextFor(plan, duration),
                              durationMinutes: durationMinutes,
                              workoutId: id,
                              warmupCount: 0,
                            ),
                          ),
                        );

                        setState(() {});
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
            ],
          ),
        ),
      ),
    );
  }
}
