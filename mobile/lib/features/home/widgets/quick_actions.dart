import 'package:flutter/material.dart';
import 'package:mobile/features/workout/all_exercises_screen.dart';



class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            "Custom\nWorkout",
            Icons.tune,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllExercisesScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            "Saved\nWorkouts",
            Icons.folder,
            onTap: () {
              // later
            },
          ),
        ),
      ],
    );
  }
}


class _ActionCard extends StatelessWidget {
  const _ActionCard(
    this.label,
    this.icon, {
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4442D9)),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


