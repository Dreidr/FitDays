import 'package:flutter/material.dart';
import 'package:mobile/features/workout/widgets/exercise_thumb.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';

class WorkoutHeaderCard extends StatelessWidget {
  const WorkoutHeaderCard({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.totalTimeText,
    required this.exercises,
    required this.onBack,
    this.muscleGroups,
  });

  final String dayLabel;
  final String title;
  final String totalTimeText;
  final VoidCallback onBack;
  final List<PlannedExercise> exercises;
  final String? muscleGroups;

  @override
  Widget build(BuildContext context) {
    final previewExercises = exercises.where((e) {
      final id = int.tryParse(e.exerciseId) ?? 0;
      return id < 1107;
    }).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4442D9).withValues(alpha: 0.85),
            const Color(0xFF2F2ECF).withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4442D9).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: back + day
          Row(
            children: [
              Text(
                dayLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Spacer(),

              Text(
                totalTimeText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (muscleGroups != null && muscleGroups!.isNotEmpty) ...[
            const SizedBox(height: 6),

            Text(
              muscleGroups!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // thumbnails
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: previewExercises.length > 5
                  ? 5
                  : previewExercises.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, index) {
                final ex = previewExercises[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: ExerciseThumb(exerciseId: ex.exerciseId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
