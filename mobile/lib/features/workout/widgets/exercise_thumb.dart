import 'package:flutter/material.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';

class ExerciseThumb extends StatelessWidget {
  const ExerciseThumb({
    super.key,
    required this.exerciseId,
  });

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.fitness_center,
        color: Colors.black54,
      ),
    );
  }
}