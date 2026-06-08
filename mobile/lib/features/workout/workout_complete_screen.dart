import 'package:flutter/material.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/workout/services/refuel_estimator.dart';
import 'package:mobile/features/workout/models/workout_history.dart';
import 'package:mobile/features/workout/services/workout_history_service.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  final String workoutId;
  final String title;

  final int plannedExercises;
  final int completedExercises;

  final int durationSeconds; // total time

  final int
  estimatedCalories; // optional (if you already compute it). can pass 0.

  const WorkoutCompleteScreen({
    super.key,
    required this.workoutId,
    required this.title,
    required this.plannedExercises,
    required this.completedExercises,
    required this.durationSeconds,
    required this.estimatedCalories,
  });

  String _timeText(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m}m ${s.toString().padLeft(2, '0')}s";
  }

  @override
  Widget build(BuildContext context) {
    const themeBlue = Color(0xFF4442D9);

    final profile = LocalStorageService.getUserProfile();
    final minutes = (durationSeconds / 60).ceil();

    final refuel = RefuelEstimator.postWorkout(
      profile: profile,
      sessionMinutes: minutes,
      workoutTitle: title,
    );

    final refuelLine =
        "Refuel target: ${refuel.proteinG}g protein • ${refuel.carbsG}g carbs • ${refuel.fatsG}g fat (~${refuel.calories} kcal)";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Header card (FitDays style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeBlue.withValues(alpha: 0.90),
                      const Color(0xFF2F2ECF).withValues(alpha: 0.90),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: themeBlue.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Workout Complete ✅",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView(
                  children: [
                    _StatRow(
                      label: "Total time",
                      value: _timeText(durationSeconds),
                      icon: Icons.timer_rounded,
                    ),
                    _StatRow(
                      label: "Estimated calories",
                      value: (estimatedCalories > 0)
                          ? "$estimatedCalories kcal"
                          : "${refuel.calories} kcal (refuel meal)",
                      icon: Icons.local_fire_department_rounded,
                    ),
                    _StatRow(
                      label: "Exercises completed",
                      value: "$completedExercises/$plannedExercises",
                      icon: Icons.fitness_center_rounded,
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "Quick refuel ideas:\n• Greek yogurt + banana\n• Chicken & rice\n• Protein shake + fruit\n• Eggs + toast",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        refuelLine,
                        style: TextStyle(
                          color: Colors.black87.withValues(alpha: 0.92),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final workoutHistory = WorkoutHistory(
                      workoutId: workoutId,
                      workoutName: title,
                      durationMinutes: (durationSeconds / 60).ceil(),
                      completedAt: DateTime.now(),
                    );

                    await WorkoutHistoryService.saveWorkout(workoutHistory);

                    if (!context.mounted) return;

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
