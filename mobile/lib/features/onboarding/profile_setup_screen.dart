import 'package:flutter/material.dart';
import 'package:mobile/features/profile/profile_screen.dart';
import 'package:mobile/features/onboarding/widgets/bottom_sheet_dropdown.dart';
import 'package:mobile/features/onboarding/widgets/bottom_sheet_slider.dart';
import 'package:mobile/features/workout/workout_schedule_field.dart';
import 'package:mobile/features/onboarding/widgets/age_picker.dart';
import 'package:mobile/features/onboarding/widgets/top_toast.dart';
import 'package:mobile/core/enums/dropdown_display.dart';
import 'package:mobile/app/app_shell.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/core/models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? name;
  String? gender;
  bool ageSelected = false;
  int? age;
  String? fitnessGoal;
  String? fitnessLevel;
  String? workoutPlan;
  int? workoutDuration;
  double weightKg = 72.5;
  bool weightChanged = false;
  List<String> workoutDays = []; // start empty
  bool get _isNameValid => (name ?? "").trim().length >= 2;
  bool get _isGenderValid => (gender ?? "").isNotEmpty;
  bool get _isAgeValid => (age ?? 0) >= 13; // change if you want
  bool get _isGoalValid => (fitnessGoal ?? "").isNotEmpty;
  bool get _isLevelValid => (fitnessLevel ?? "").isNotEmpty;
  bool get _isScheduleValid => workoutDays.isNotEmpty;
  bool get _isDurationValid => (workoutDuration ?? 0) > 0;
  bool get _isPlanValid => (workoutPlan ?? "").isNotEmpty;

  bool get _canSave =>
      _isNameValid &&
      _isGenderValid &&
      _isAgeValid &&
      _isGoalValid &&
      _isLevelValid &&
      _isScheduleValid &&
      _isDurationValid &&
      _isPlanValid;

  String _firstErrorMessage() {
    if (!_isNameValid) return "Please enter your name";
    if (!_isGenderValid) return "Please select your gender";
    if (!_isAgeValid) return "Please select your age";
    if (!_isGoalValid) return "Please select your fitness goal";
    if (!_isLevelValid) return "Please select your fitness level";
    if (!_isScheduleValid) return "Please select workout days";
    if (!_isDurationValid) return "Please select workout duration";
    if (!_isPlanValid) return "Please select workout plan";
    return "Please complete your profile";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Plan Setup",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LocalStorageService.setOnboardingSkipped(true);

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AppShell(
                    userName: "User",
                    workoutStreak: 0,
                    startDate: DateTime.now(),
                    workoutDays: const [],
                  ),
                ),
                (route) => false,
              );
            },

            child: const Text(
              "Skip for now",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),

      // ✅ sticky bottom button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave
                  ? () async {
                      final profile = UserProfile(
                        name: (name ?? "").trim(),
                        gender: gender ?? "",
                        age: age ?? 0,
                        fitnessGoal: fitnessGoal ?? "",
                        fitnessLevel: fitnessLevel ?? "",
                        workoutPlan: workoutPlan ?? "",
                        workoutDuration: workoutDuration ?? 0,
                        weightKg: weightKg,
                        workoutDays: workoutDays,
                      );

                      await LocalStorageService.saveUserProfile(profile);
                      await LocalStorageService.setOnboardingComplete(true);

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppShell(
                            userName: profile.name.isEmpty
                                ? "User"
                                : profile.name,
                            workoutStreak: 0,
                            startDate: DateTime.now(),
                            workoutDays: profile.workoutDays,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  : () {
                      // nice UX: tell user what’s missing
                      showTopToast(context, _firstErrorMessage());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave
                    ? const Color(0xFF4442D9)
                    : const Color(0xFF4442D9).withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _canSave ? 1 : 0,
              ),
              child: Text(
                _canSave ? "Save" : "Complete setup",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PROFILE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 8),

            ProfileNameField(
              value: name,
              showBorder: false, // 👈 clean list style
              onChanged: (val) => setState(() => name = val),
            ),

            const Divider(
              height: 6, // space around line
              thickness: 0.6, // thin line
              indent: 14, // left padding
              endIndent: 14, // right padding
              color: Colors.black12,
            ),

            const SizedBox(height: 8),

            BottomSheetDropdown(
              placeholder: "Gender",
              value: gender,
              display: DropdownDisplay.trailingValue,
              showBorder: false, // 👈 clean list style
              options: const ["Male", "Female", "Other", "Prefer Not To Say"],
              onChanged: (val) {
                setState(() => gender = val);
                showTopToast(context, "Profile Data Updated");
              },
            ),
            const Divider(
              height: 6, // space around line
              thickness: 0.6, // thin line
              indent: 14, // left padding
              endIndent: 14, // right padding
              color: Colors.black12,
            ),

            const SizedBox(height: 8),

            AgePickerField(
              value: age,
              isSelected: ageSelected,
              showBorder: false, // 👈 clean list style
              onChanged: (val) {
                setState(() {
                  age = val;
                  ageSelected = true;
                });
                showTopToast(context, "Profile Data Updated");
              },
            ),

            const Divider(
              height: 6, // space around line
              thickness: 0.6, // thin line
              indent: 14, // left padding
              endIndent: 14, // right padding
              color: Colors.black12,
            ),

            const SizedBox(height: 16),

            const Text(
              "FITNESS GOAL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 12),

            BottomSheetDropdown(
              placeholder: "Set My Goal",
              value: fitnessGoal,
              options: const [
                "Lose Weight",
                "Build Muscle",
                "Maintain Fitness",
                "Improve Endurance",
                "Get Stronger",
              ],
              onChanged: (val) {
                setState(() => fitnessGoal = val);
                showTopToast(context, "Fitness Goal updated");
              },
            ),

            const SizedBox(height: 12),

            BottomSheetSlider(
              placeholder: "Weight Goal",
              unit: "kg",
              value: weightKg,
              min: 35,
              max: 160,
              divisions: 250, // 0.5kg steps if you want: (160-35)*2=250
              isSet: weightChanged, // 👈 now recognized
              onChanged: (v) {
                setState(() {
                  weightKg = v;
                  weightChanged =
                      true; // only becomes true after user moves slider
                  showTopToast(context, "Weight Goal updated");
                });
              },
            ),

            const SizedBox(height: 16),

            const Text(
              "WORKOUT PARAMETERS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 12),

            BottomSheetDropdown(
              placeholder: "Fitness Level",
              value: fitnessLevel,
              options: const ["Beginner", "Intermediate", "Advanced"],
              onChanged: (val) {
                setState(() => fitnessLevel = val);
                showTopToast(context, "Fitness Level updated");
              },
            ),

            const SizedBox(height: 12),

            WorkoutScheduleField(
              placeholder: "Workout Schedule",
              value: workoutDays,
              onChanged: (val) {
                setState(() => workoutDays = val);
                showTopToast(context, "Workout Schedule updated");
              },
            ),
            const SizedBox(height: 12),

            BottomSheetDropdown(
              placeholder: "Workout Duration",
              value: workoutDuration == null ? null : "$workoutDuration min",
              options: const ["30 min", "40 min", "50 min", "60 min"],
              onChanged: (val) {
                setState(() {
                  workoutDuration = int.parse(
                    val.split(" ").first,
                  ); // 👈 extract number
                  showTopToast(context, "Workout Duration updated");
                });
              },
            ),

            const SizedBox(height: 12),

            BottomSheetDropdown(
              placeholder: "Workout Plan",
              value: workoutPlan,
              options: const [
                "Strength Training",
                "Cardio",
                "Flexibility Training",
                "Stability Training",
              ],
              onChanged: (val) {
                setState(() => workoutPlan = val);
                showTopToast(context, "Workout Plan updated");
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
