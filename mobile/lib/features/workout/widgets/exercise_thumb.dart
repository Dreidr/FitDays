import 'package:flutter/material.dart';

class ExerciseThumb extends StatelessWidget {
  final String exerciseId;

  const ExerciseThumb({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/thumbnails/$exerciseId.jpg',
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            color: Colors.grey,
            child: const Icon(Icons.fitness_center),
          );
        },
      ),
    );
  }
}