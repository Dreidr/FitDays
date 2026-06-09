import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/features/workout/exercise_detail_screen.dart';
import 'package:mobile/features/workout/widgets/exercise_thumb.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout_play/workout_play_screen.dart';
import 'package:mobile/app/theme/app_decorations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/features/workout/models/saved_workout.dart';
import 'package:mobile/core/services/local_storage_services.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.totalTimeText,
    required this.workoutId, // ✅ new,
    required this.warmupCount,
  });

  final String dayLabel;
  final String title;
  final String totalTimeText;
  final String workoutId;
  final int warmupCount; // ✅

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Future<List<Map<String, dynamic>>> _future = Future.value(const []);

  bool _warmupOn = true;
  bool _warmupVisible = false;
  SavedWorkout? _savedWorkout; // ✅ ADD THIS

  List<PlannedExercise> _userPlan = [];
  List<PlannedExercise> _warmupPlan = []; // ✅ warmup LIST (not a method)
  List<Map<String, dynamic>> _allExercises = []; // ✅ dataset cache

  List<Map<String, dynamic>> _lastApiItems = [];

  @override
  void initState() {
    super.initState();

    // ✅ Load saved workout (source of truth)
    _savedWorkout = LocalStorageService.getSavedWorkoutById(widget.workoutId);

    // If not found, start with empty plan (and show UI message later)
    _userPlan = List.of(_savedWorkout?.exercises ?? const <PlannedExercise>[]);

    () async {
      _allExercises = await LocalExerciseRepo.loadAll();

      // only generate warm-up if toggle is ON
      if (_warmupOn) {
        _warmupPlan = _generateRandomWarmup();
      } else {
        _warmupPlan = [];
      }

      // ✅ now load exercises AFTER warm-up list is ready
      _future = _loadExercises();

      if (mounted) setState(() {});
    }();
  }

  static const int _warmupCount = 4;

  List<PlannedExercise> _generateRandomWarmup() {
    if (_allExercises.isEmpty) return [];

    bool isWarmupCandidate(Map<String, dynamic> e) {
      final cat = (e["category"] ?? "").toString().toLowerCase();
      final eq = (e["equipment"] ?? "").toString().toLowerCase();

      if (cat != "cardio" && cat != "stretching") return false;

      // dataset may use: body weight / body only / other
      final okEq = eq.contains("body") || eq.contains("other");
      return okEq;
    }

    final pool = _allExercises.where(isWarmupCandidate).toList();
    if (pool.isEmpty) return [];

    pool.shuffle();

    // ✅ take up to 5
    final picked = pool.take(_warmupCount).toList();

    return picked.map((e) {
      final id = (e["id"] ?? "").toString();
      final cat = (e["category"] ?? "").toString().toLowerCase();

      // simple warm-up prescription
      if (cat == "cardio") {
        return PlannedExercise(
          exerciseId: id,
          sets: 1,
          reps: 30, // 30 seconds / reps-ish
          weightKg: null,
        );
      }

      // stretching
      return PlannedExercise(exerciseId: id, sets: 1, reps: 20, weightKg: null);
    }).toList();
  }

  List<PlannedExercise> get _activePlan {
    if (!_warmupOn) return _userPlan;
    return [..._warmupPlan, ..._userPlan];
  }

  Future<List<Map<String, dynamic>>> _loadExercises() {
    final ids = _activePlan.map((e) => e.exerciseId).toList();
    return LocalExerciseRepo.fetchExercisesByIds(ids);
  }

  void _toggleWarmup(bool v) {
    setState(() {
      _warmupOn = v;

      if (!_warmupOn) {
        _warmupVisible = false; // collapse if off
      } else {
        _warmupPlan = _generateRandomWarmup(); // randomize when turned on
      }

      _future =
          _loadExercises(); // still reload because active IDs changed for play list
    });
  }

  void _editExercise(int index) {
    final current = _userPlan[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _EditExerciseSheet(
        initial: current,
        onSave: (updated) {
          setState(() {
            _userPlan[index] = updated;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _startWorkout() async {
    final playList = _warmupOn ? [..._warmupPlan, ..._userPlan] : _userPlan;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPlayScreen(
          workoutId: widget.workoutId,
          dayLabel: widget.dayLabel,
          title: widget.title,
          exercises: playList,
          warmupCount: _warmupOn ? _warmupPlan.length : 0,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {}); // ✅ forces rebuild
  }

  String _s(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final active = LocalStorageService.getActiveWorkoutSession();
    final hasActiveSession = active?.workoutId == widget.workoutId;
    final isCompletedToday = LocalStorageService.isWorkoutCompletedOnDay(
      DateTime.now(),
    );
    final buttonText = hasActiveSession
        ? "Resume Workout"
        : isCompletedToday
        ? "Train Again"
        : "Start Workout";

    final buttonColor = hasActiveSession
        ? const Color(0xFF4442D9)
        : isCompletedToday
        ? const Color(0xFF2ECC71)
        : const Color(0xFF4442D9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  // ✅ no blink: show previous content while loading
                  final isLoading =
                      snap.connectionState == ConnectionState.waiting;

                  final apiItems =
                      snap.data ?? (isLoading ? _lastApiItems : const []);
                  if (!isLoading && snap.hasData) {
                    // ✅ update cache only when we have fresh data
                    _lastApiItems = snap.data!;
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          snap.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  final planItems =
                      _userPlan; // ✅ main list = only workout exercises

                  final apiById = <String, Map<String, dynamic>>{
                    for (final ex in apiItems) _s(ex['id']): ex,
                  };

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderCard(
                          dayLabel: widget.dayLabel,
                          title: widget.title,
                          exerciseCount: planItems.length,
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Total time: ${widget.totalTimeText}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
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
                                    value: _warmupOn,
                                    onChanged: _toggleWarmup,
                                    activeThumbColor: Colors.white, // thumb
                                    
                                    activeTrackColor: const Color(
                                      0xFF4442D9,
                                    ), // track (ON)
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.black26,
                                  ),

                                  // Chevron button (disabled when switch off)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: _warmupOn
                                        ? () => setState(
                                            () => _warmupVisible =
                                                !_warmupVisible,
                                          )
                                        : null,
                                    icon: Icon(
                                      _warmupVisible
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: _warmupOn
                                          ? Colors.black54
                                          : Colors.black26,
                                    ),
                                  ),
                                ],
                              ),

                              // ✅ Expanded warm-up list
                              if (_warmupOn && _warmupVisible) ...[
                                const SizedBox(height: 10),

                                if (_warmupPlan.isEmpty)
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "No warm-up exercises found in dataset.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                else
                                  ..._warmupPlan.map((p) {
                                    final ex = apiById[p.exerciseId];

                                    final name = ex == null
                                        ? "Warm-up"
                                        : _s(ex['name']);
                                    final cat = ex == null
                                        ? ""
                                        : _s(ex['category']);

                                    final subtitle = [
                                      p.metaText(),
                                      if (cat.isNotEmpty) cat,
                                    ].join(" • ");

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: _ExerciseRow(
                                        exerciseId: p.exerciseId,
                                        name: name.isEmpty ? "Warm-up" : name,
                                        meta: subtitle,
                                        onMore: () {},
                                        onTap: () {
                                          if (ex == null) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ExerciseDetailScreen(
                                                    exercise: ex,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ Reorder + swipe-delete main list (user plan only)
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // because you're inside SingleChildScrollView
                          buildDefaultDragHandles: false,
                          itemCount: planItems.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = _userPlan.removeAt(oldIndex);
                              _userPlan.insert(newIndex, item);
                            });
                            // No need to reload _future because IDs didn't change.
                          },
                          itemBuilder: (context, i) {
                            final planned = planItems[i];
                            final ex = apiById[planned.exerciseId];
                            final name = ex == null
                                ? "Missing exercise"
                                : _s(ex['name']);

                            return Slidable(
                              key: ValueKey(
                                planned,
                              ), // IMPORTANT: unique per row (better than index)
                              endActionPane: ActionPane(
                                extentRatio:
                                    0.28, // 👈 smaller = tighter delete button
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      setState(() {
                                        _userPlan.removeAt(i);
                                        _future =
                                            _loadExercises(); // reload because IDs changed
                                      });
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
                                child: _ExerciseRow(
                                  exerciseId: planned.exerciseId,
                                  name: name.isEmpty ? "Exercise" : name,
                                  meta: planned.metaText(),
                                  onMore: () => _editExercise(i),
                                  reorderIndex:
                                      i, // ✅ new (see _ExerciseRow change below)
                                  onTap: () {
                                    if (ex == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                        builder: (_) =>
                                            ExerciseDetailScreen(exercise: ex),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 6),

                        // (optional) you can compute muscle groups/equipment from apiItems
                        // we can do that next.
                      ],
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _startWorkout,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.dayLabel,
    required this.title,
    required this.exerciseCount,
    required this.onBack,
  });

  final String dayLabel;
  final String title;
  final int exerciseCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "$exerciseCount exercises",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // thumbnails
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, _) => ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(width: 56, color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  class _ExerciseRow extends StatelessWidget {
    const _ExerciseRow({
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

class _EditExerciseSheet extends StatefulWidget {
  const _EditExerciseSheet({required this.initial, required this.onSave});

  final PlannedExercise initial;
  final ValueChanged<PlannedExercise> onSave;

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
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
