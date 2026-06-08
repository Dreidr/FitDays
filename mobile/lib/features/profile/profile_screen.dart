import 'package:flutter/material.dart';
import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/onboarding/widgets/top_toast.dart';
import 'package:mobile/features/settings/app_settings_screen.dart';
import 'package:mobile/features/profile/widgets/profile_header_card.dart';
import 'package:mobile/features/plan/models/plan_settings.dart';
import 'package:mobile/features/plan/plan_details_screen.dart';
import 'package:mobile/features/workout/services/day_plan_builder.dart';
import 'package:mobile/features/workout/services/workout_history_service.dart';
import 'package:mobile/features/plan/models/session_progress.dart';
import 'package:mobile/features/workout/services/plan_calendar_service.dart';

const double _rowLeftInset = 8;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userNameVN, // fallback from AppShell ("User" or real)
    required this.onProfileUpdated,
  });

  final ValueNotifier<String> userNameVN;
  final VoidCallback onProfileUpdated;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // What the header shows (only changes AFTER Save)
  int _completedWorkouts = 0;
  int _workoutMinutes = 0;
  String _savedName = "User";

  // What user is typing (can change freely)
  String _draftName = "";

  String _savedEmail = "";
  String _draftEmail = "";

  // Optional: show a small loading indicator when saving
  bool _saving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _loadStats();

    final profile = LocalStorageService.getUserProfile();
    final stored = profile?.name?.trim() ?? "";
    final storedEmail = profile?.email.trim() ?? "";

    _savedName = stored.isNotEmpty ? stored : widget.userNameVN.value;
    _draftName = _savedName;

    _savedEmail = storedEmail;
    _draftEmail = storedEmail;

    _nameController = TextEditingController(
      text: (_savedName == "User") ? "" : _savedName,
    );

    _emailController = TextEditingController(text: _savedEmail);

    // cursor at end
    _nameController.selection = TextSelection.collapsed(
      offset: _nameController.text.length,
    );
    _emailController.selection = TextSelection.collapsed(
      offset: _emailController.text.length,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final history = await WorkoutHistoryService.getWorkoutHistory();

    setState(() {
      _completedWorkouts = history.length;

      _workoutMinutes = history.fold(
        0,
        (sum, workout) => sum + workout.durationMinutes,
      );
    });
  }

  Future<void> _saveProfile() async {
    final safeName = _draftName.trim().isEmpty ? "User" : _draftName.trim();
    final safeEmail = _draftEmail.trim();

    setState(() => _saving = true);

    final existing = LocalStorageService.getUserProfile();

    final today = DateTime.now();
    final cleanStartDate = DateTime(
      today.year,
      today.month,
      today.day,
    ); // date-only

    final updated =
        (existing ??
                UserProfile(
                  name: safeName,
                  email: safeEmail,
                  startDate: cleanStartDate, // ✅ REQUIRED
                  // defaults for MVP:
                  gender: "",
                  age: 0,
                  fitnessGoal: "",
                  fitnessLevel: "",
                  workoutPlan: "",
                  workoutDuration: 0,
                  weightKg: 0.0,
                  workoutDays: const [],
                ))
            .copyWith(
              name: safeName, // ✅ also save name
              email: safeEmail, // ✅ save email
            );

    await LocalStorageService.saveUserProfile(updated);

    if (!mounted) return;

    setState(() {
      _savedName = safeName;
      _draftName = safeName;

      _savedEmail = safeEmail;
      _draftEmail = safeEmail;

      _saving = false;
    });

    widget.userNameVN.value = safeName;
    showTopToast(context, "Profile Data Updated");
  }

  List<WeekProgress> _buildProgress(UserProfile profile) {
    final plans = DayPlanBuilder.buildWeek(
      startDate: profile.startDate,
      workoutDays: profile.workoutDays,
      durationMinutes: profile.workoutDuration ?? 40,
      profile: profile,
    );

    return [
      WeekProgress(
        weekNumber: 1,
        sessions: plans
            .where((p) => p.isWorkoutDay)
            .map(
              (p) => SessionItem(
                dayLabel: PlanCalendarService.dayLabel(p.date),
                title: p.title,
                minutes: profile.workoutDuration ?? 40,
                completed: false,
              ),
            )
            .toList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header card (shows saved name only)
              ProfileHeaderCard(
                userName: _savedName,
                streak: 2,
                workoutMinutes: _workoutMinutes,
                completedWorkouts: _completedWorkouts,
                onSettingsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppSettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Plan details button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF4442D9), // 👈 border color
                      width: 1.5,
                    ),
                    foregroundColor: const Color(
                      0xFF4442D9,
                    ), // 👈 text + icon color
                  ),
                  onPressed: () {
                    final profile = LocalStorageService.getUserProfile();

                    if (profile == null) return;

                    final plan = PlanSettings(
                      workoutsPerWeek: profile.workoutDays.length,
                      workoutType: profile.workoutPlan ?? "Custom Plan",
                      durationMin: profile.workoutDuration ?? 45,
                      fitnessGoal: profile.fitnessGoal ?? "General Fitness",
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlanDetailsScreen(
                          plan: plan,
                          progress: _buildProgress(profile),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Plan Details",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // First name (inline edit, no modal)
              Padding(
                padding: const EdgeInsets.only(left: _rowLeftInset),
                child: const Text(
                  "Name",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                onChanged: (v) => _draftName = v,
                decoration: const InputDecoration(
                  hintText: "Enter your name",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Placeholder rows (keep layout same; wire later)
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.only(left: _rowLeftInset),
                child: const Text(
                  "Email address",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => _draftEmail = v,
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text("************", style: TextStyle(fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: change password flow later
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
              const Divider(height: 1),

              const SizedBox(height: 22),

              // Save + optional cancel
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4442D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _saving ? null : _saveProfile,
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            height: 1.2,
            color: Color(0xFF555555),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


