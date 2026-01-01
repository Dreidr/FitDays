import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/bottom_sheet_dropdown.dart';
import 'package:mobile/core/widgets/bottom_sheet_slider.dart';
import 'package:mobile/core/widgets/workout_schedule_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? fitnessGoal;
  String? fitnessLevel;
  double weightKg = 72.5;
  bool weightChanged = false;
  List<String> workoutDays = []; // start empty

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fitness goal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            BottomSheetDropdown(
              placeholder: "Select Goal",
              value: fitnessGoal,
              options: const [
                "Lose weight",
                "Build muscle",
                "Maintain fitness",
                "Improve endurance",
                "Get stronger",
              ],
              onChanged: (val) {
                setState(() => fitnessGoal = val);
              },
            ),

            const SizedBox(height: 12),

            BottomSheetSlider(
              placeholder: "Weight",
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
                });
              },
            ),

            const SizedBox(height: 48),

            const Text(
              "Workout parameters",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            BottomSheetDropdown(
              placeholder: "Fitness Level",
              value: fitnessLevel,
              options: const ["Beginner", "Intermediate", "Advanced"],
              onChanged: (val) {
                setState(() => fitnessLevel = val);
              },
            ),

            const SizedBox(height: 12),

            WorkoutScheduleField(
              placeholder: "Workout Schedule",
              value: workoutDays,
              onChanged: (val) => setState(() => workoutDays = val),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
