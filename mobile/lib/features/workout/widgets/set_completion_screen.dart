import '../../workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:flutter/material.dart';

class SetCompletionScreen extends StatelessWidget {
  final PlannedExercise completedExercise;
  final PlannedExercise? nextExercise;

  final String completedName;
  final String? nextName;

  const SetCompletionScreen({
    super.key,
    required this.completedExercise,
    required this.nextExercise,
    required this.completedName,
    required this.nextName,
  });

  @override
  Widget build(BuildContext context) {
    final weight = completedExercise.weightKg;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              const Icon(
                Icons.check_circle_rounded,
                size: 90,
                color: Colors.green,
              ),

              const SizedBox(height: 24),

              Text(
                completedName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: List.generate(
                    completedExercise.sets,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            "Set ${i + 1}",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),

                          const Spacer(),

                          Text(
                            "${completedExercise.reps} reps"
                            " × "
                            "${(completedExercise.weightKg ?? 0).toInt()}kg",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              if (nextExercise != null) ...[
                const Text(
                  "Up Next",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  nextName ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  weight == null || weight == 0
                      ? "${nextExercise!.sets} × ${nextExercise!.reps}"
                      : "${nextExercise!.sets} × ${nextExercise!.reps} @ ${weight.toInt()}kg",
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    nextExercise == null
                        ? "Finish Workout"
                        : "Start Next Exercise",
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
