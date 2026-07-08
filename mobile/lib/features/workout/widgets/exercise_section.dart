import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/features/workout/widgets/exercise_row.dart';
import 'package:mobile/features/workout/exercise_detail_screen.dart';

class ExerciseSection extends StatelessWidget {
  const ExerciseSection({
    super.key,
    required this.planItems,
    required this.exerciseById,
    required this.onDelete,
    required this.onEdit,
    required this.onReorder,
  });

  final List<PlannedExercise> planItems;

  final Map<String, Map<String, dynamic>> exerciseById;

  final Future<void> Function(int index) onDelete;

  final void Function(int index, PlannedExercise exercise) onEdit;

  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  @override
  Widget build(BuildContext context) {
    String s(dynamic v) => (v ?? '').toString();
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // because you're inside SingleChildScrollView
      buildDefaultDragHandles: false,
      itemCount: planItems.length,
      onReorder: (oldIndex, newIndex) async {
        await onReorder(oldIndex, newIndex);
      },
      itemBuilder: (context, i) {
        final planned = planItems[i];
        final ex = exerciseById[planned.exerciseId];
        final name = ex == null ? "Missing exercise" : s(ex['name']);

        return Slidable(
          key: ValueKey(
            planned,
          ), // IMPORTANT: unique per row (better than index)
          endActionPane: ActionPane(
            extentRatio: 0.28, // 👈 smaller = tighter delete button
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) async {
                  await onDelete(i);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: "Delete",
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExerciseRow(
              exerciseId: planned.exerciseId,
              name: name.isEmpty ? "Exercise" : name,
              meta: planned.metaText(),
              onMore: () => onEdit(i, planned),
              reorderIndex: i, // ✅ new (see _ExerciseRow change below)
              onTap: () {
                if (ex == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Exercise not found: ${planned.exerciseId}",
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseDetailScreen(
                      exercise: ex,
                      plannedExercise: planned,
                      onReplace: () async {
                        onEdit(i, planned);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
