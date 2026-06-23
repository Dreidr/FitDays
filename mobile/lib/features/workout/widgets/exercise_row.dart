import 'package:flutter/material.dart';
import 'package:mobile/features/workout/widgets/exercise_thumb.dart';

class ExerciseRow extends StatelessWidget {
  const ExerciseRow({
    super.key,
    required this.exerciseId,
    required this.name,
    required this.meta,
    required this.onMore,
    this.reorderIndex,
    required this.onTap,
  });

  final String exerciseId;
  final String name;
  final String meta;
  final VoidCallback onMore;
  final int? reorderIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 54,
                height: 54,
                child: exerciseId.isEmpty
                    ? const Icon(
                        Icons.image_not_supported,
                        color: Colors.black54,
                      )
                    : ExerciseThumb(exerciseId: exerciseId), // ✅ your widget
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz, color: Colors.black54),
            ),
            if (reorderIndex != null)
              ReorderableDragStartListener(
                index: reorderIndex!,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.drag_handle, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
