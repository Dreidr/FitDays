import 'package:flutter/material.dart';

class WorkoutBottomActions extends StatelessWidget {
  const WorkoutBottomActions({
    super.key,
    required this.buttonText,
    required this.buttonColor,
    required this.canUndoWorkout,
    required this.onStartWorkout,
    required this.onGenerateWorkout,
    required this.onUndoWorkout,
  });

  final String buttonText;
  final Color buttonColor;
  final bool canUndoWorkout;

  final VoidCallback onStartWorkout;
  final VoidCallback onGenerateWorkout;
  final VoidCallback onUndoWorkout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onStartWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canUndoWorkout
                    ? onUndoWorkout
                    : onGenerateWorkout,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  canUndoWorkout ? "Undo" : "New Workout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: canUndoWorkout
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}