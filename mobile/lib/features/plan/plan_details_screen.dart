import 'package:flutter/material.dart';
import 'models/plan_settings.dart';
import 'models/session_progress.dart';
import 'package:mobile/features/onboarding/profile_setup_screen.dart';
import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/core/services/local_storage_services.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({
    super.key,
    required this.plan,
    required this.progress,
  });

  final PlanSettings plan;
  final List<WeekProgress> progress;

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  late PlanSettings _plan;
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = LocalStorageService.getUserProfile()!;
    _plan = _planFromProfile(_profile);
  }

  Future<void> _openEditPlan() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(returnResultOnly: true, allowSkip: false,),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _profile = updated;
        _plan = _planFromProfile(updated);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4442D9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Plan Details",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Info cards (2x2)
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: "${_plan.workoutsPerWeek} workouts",
                      subtitle: "Per Week",
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoCard(
                      title: _plan.workoutType,
                      subtitle: "Workout Type",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: "${_plan.durationMin} min",
                      subtitle: "Duration",
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoCard(
                      title: _plan.fitnessGoal,
                      subtitle: "Fitness Goal",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Edit plan settings button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: purple.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: _openEditPlan,
                  icon: const SizedBox.shrink(),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Edit Plan Settings",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Icon(Icons.settings, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Session progress",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),

              // Weeks
              ...widget.progress.map((w) => _WeekCard(week: w)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4442D9);

    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week});
  final WeekProgress week;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Week ${week.weekNumber}",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...week.sessions.map(_SessionRow.new),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow(this.s);

  final SessionItem s;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4442D9);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: Colors.white.withValues(alpha: s.completed ? 1 : 0.35),
                  size: 18,
                ),
                const SizedBox(height: 2),
                Text(
                  s.dayLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${s.minutes} min",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

PlanSettings _planFromProfile(UserProfile p) {
  return PlanSettings(
    workoutsPerWeek: p.workoutDays.length,
    workoutType: p.workoutPlan ?? "—",
    durationMin: p.workoutDuration ?? 0,
    fitnessGoal: p.fitnessGoal ?? "—",
  );
}
