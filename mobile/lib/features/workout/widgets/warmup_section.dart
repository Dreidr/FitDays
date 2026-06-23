import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/app/theme/app_decorations.dart';
import 'package:mobile/features/workout/exercise_detail_screen.dart';
import 'package:mobile/features/workout/widgets/exercise_row.dart';

class WarmupSection extends StatelessWidget {
  const WarmupSection({
    super.key,
    required this.warmupOn,
    required this.warmupVisible,
    required this.warmupPlan,
    required this.exerciseById,
    required this.onToggleWarmup,
    required this.onToggleVisible,
    required this.onDeleteWarmup,
    required this.onEditWarmup,
  });

  final bool warmupOn;
  final bool warmupVisible;

  final List<PlannedExercise> warmupPlan;

  final Map<String, Map<String, dynamic>> exerciseById;

  final ValueChanged<bool> onToggleWarmup;
  final VoidCallback onToggleVisible;

  final Future<void> Function(PlannedExercise) onDeleteWarmup;
  final void Function(PlannedExercise) onEditWarmup;

  @override
  Widget build(BuildContext context) {
    String s(dynamic v) => (v ?? '').toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppDecorations.card(context),
      child: Column(
        children: [
          // ✅ ONE ROW: title + chevron + switch
          Row(
            children: [
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Warm-up",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Switch with app color
              Switch(
                value: warmupOn,
                onChanged: onToggleWarmup,
                activeThumbColor: Colors.white, // thumb

                activeTrackColor: const Color(0xFF4442D9), // track (ON)
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.black26,
              ),

              // Chevron button (disabled when switch off)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: warmupOn ? onToggleVisible : null,
                icon: Icon(
                  warmupVisible ? Icons.expand_less : Icons.expand_more,
                  color: warmupOn ? Colors.black54 : Colors.black26,
                ),
              ),
            ],
          ),

          // ✅ Expanded warm-up list
          if (warmupOn && warmupVisible) ...[
            const SizedBox(height: 10),

            if (warmupPlan.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "No warm-up exercises found in dataset.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              )
            else
              ...warmupPlan.map((p) {
                final ex = exerciseById[p.exerciseId];

                final name = ex == null ? "Warm-up" : s(ex['name']);
                final cat = ex == null ? "" : s(ex['category']);

                final subtitle = [
                  p.metaText(),
                  if (cat.isNotEmpty) cat,
                ].join(" • ");

                return Slidable(
                  key: ValueKey(p),
                  endActionPane: ActionPane(
                    extentRatio: 0.28,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          await onDeleteWarmup(p);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: "Delete",
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ExerciseRow(
                      exerciseId: p.exerciseId,
                      name: name.isEmpty ? "Warm-up" : name,
                      meta: subtitle,
                      onMore: () => onEditWarmup(p),
                      onTap: () {
                        if (ex == null) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: ex),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}
