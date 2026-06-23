import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout/all_exercises_screen.dart';

class EditExerciseSheet extends StatefulWidget {
  const EditExerciseSheet({
    super.key,
    required this.initial,
    required this.onSave,
  });

  final PlannedExercise initial;
  final ValueChanged<PlannedExercise> onSave;

  @override
  State<EditExerciseSheet> createState() => EditExerciseSheetState();
}

class EditExerciseSheetState extends State<EditExerciseSheet> {
  late int _sets;
  late int _reps;
  late TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _sets = widget.initial.sets;
    _reps = widget.initial.reps;

    final w = widget.initial.weightKg;
    _weightCtrl = TextEditingController(
      text: (w != null && w > 0) ? w.toStringAsFixed(0) : "",
    );
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  double? _parseWeight() {
    final t = _weightCtrl.text.trim();
    if (t.isEmpty) return null;

    final v = double.tryParse(t);
    if (v == null || v <= 0) return null;

    // round to 0.5kg for nicer values
    return (v * 2).round() / 2.0;
  }

  PlannedExercise _buildUpdated() {
    return PlannedExercise(
      exerciseId: widget.initial.exerciseId,
      sets: _sets,
      reps: _reps,
      weightKg: _parseWeight(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Edit exercise",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),

          _StepperRow(
            label: "Sets",
            value: _sets,
            min: 1,
            max: 8,
            onChanged: (v) => setState(() => _sets = v),
          ),
          const SizedBox(height: 10),
          _StepperRow(
            label: "Reps",
            value: _reps,
            min: 1,
            max: 30,
            onChanged: (v) => setState(() => _reps = v),
          ),

          const SizedBox(height: 12),

          const Text(
            "Weight (kg)",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "Leave blank to set later",
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  final currentExercise = await LocalExerciseRepo.getById(
                    widget.initial.exerciseId,
                  );

                  final target = currentExercise?["target"];

                  final replacement = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllExercisesScreen(
                        targetFilter: target,
                        selectionMode: true,
                        warmupOnly: true,
                      ),
                    ),
                  );

                  if (replacement == null) return;

                  widget.onSave(
                    PlannedExercise(
                      exerciseId: replacement["id"].toString(),
                      sets: _sets,
                      reps: _reps,
                      weightKg: _parseWeight(),
                    ),
                  );
                },
                icon: const Icon(Icons.swap_horiz, size: 22),
                label: const Text(
                  "Replace Exercise",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _weightCtrl.text = ""),
                child: const Text("Clear weight"),
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4442D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => widget.onSave(_buildUpdated()),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            "$value",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
