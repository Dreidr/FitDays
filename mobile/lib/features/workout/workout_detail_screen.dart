import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/features/workout/widgets/exercise_section.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout_play/workout_play_screen.dart';
import 'package:mobile/features/workout/widgets/warmup_section.dart';
import 'package:mobile/features/workout/models/saved_workout.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/workout/services/workout_generator.dart';
import 'package:mobile/features/workout/all_exercises_screen.dart';
import 'package:mobile/features/workout/widgets/workout_header_card.dart';
import 'package:mobile/features/workout/widgets/edit_exercise_sheet.dart';
import 'package:mobile/features/workout/widgets/workout_bottom_actions.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.totalTimeText,
    required this.workoutId, // ✅ new,
    required this.warmupCount,
    required this.plan,
  });

  final DayPlan plan;
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
  List<Map<String, dynamic>> _lastExerciseItems = [];

  @override
  void initState() {
    super.initState();

    // ✅ Load saved workout (source of truth)
    _savedWorkout = LocalStorageService.getSavedWorkoutById(widget.workoutId);

    final allExercises = List<PlannedExercise>.from(
      _savedWorkout?.exercises ?? const <PlannedExercise>[],
    );

    _warmupPlan = allExercises.where((e) {
      final id = int.tryParse(e.exerciseId) ?? 0;
      return id >= 1107;
    }).toList();

    _userPlan = allExercises.where((e) {
      final id = int.tryParse(e.exerciseId) ?? 0;
      return id < 1107;
    }).toList();

    () async {
      _future = _loadExercises();

      if (mounted) setState(() {});
      await _saveCurrentWorkout();
    }();
  }

  Future<List<Map<String, dynamic>>> _loadExercises() {
    final ids = _userPlan.map((e) => e.exerciseId).toList();
    return LocalExerciseRepo.fetchExercisesByIds(ids);
  }

  void _toggleWarmup(bool v) async {
    setState(() {
      _warmupOn = v;

      if (!_warmupOn) {
        _warmupVisible = false;
      }

      _future = _loadExercises();
    });

    await _saveCurrentWorkout();
  }

  void _editExerciseWarmup(PlannedExercise current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => EditExerciseSheet(
        initial: current,
        onSave: (updated) {
          setState(() {
            final index = _warmupPlan.indexWhere(
              (e) => e.exerciseId == current.exerciseId,
            );

            if (index != -1) {
              _warmupPlan[index] = updated;
            }
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  void _editExerciseWorkout(int index, PlannedExercise current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => EditExerciseSheet(
        initial: current,
        onSave: (updated) {
          setState(() {
            _userPlan[index] = updated;
            _future = _loadExercises();
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  SavedWorkout? _previousWorkout;
  bool _canUndoWorkout = false;

  Future<void> _generateNewWorkout() async {
    final profile = LocalStorageService.getUserProfile();

    final generated = await WorkoutGenerator.generatePlannedExercises(
      profile: profile,
      plan: widget.plan,
    );

    final existing = LocalStorageService.getSavedWorkoutById(widget.workoutId);

    if (existing == null) return;

    // Save previous workout for Undo
    _previousWorkout = existing;

    final updated = SavedWorkout(
      id: existing.id,
      createdAt: existing.createdAt,
      title: existing.title,
      durationMinutes: existing.durationMinutes,
      warmupOn: true,
      exercises: generated,
    );

    await LocalStorageService.saveGeneratedWorkout(updated);

    setState(() {
      _savedWorkout = updated;
      _canUndoWorkout = true;

      _warmupPlan = generated.where((e) {
        final id = int.tryParse(e.exerciseId) ?? 0;
        return id >= 1107;
      }).toList();

      _userPlan = generated.where((e) {
        final id = int.tryParse(e.exerciseId) ?? 0;
        return id < 1107;
      }).toList();

      _future = _loadExercises();
    });
  }

  Future<void> _undoWorkoutGeneration() async {
    if (_previousWorkout == null) return;

    await LocalStorageService.saveGeneratedWorkout(_previousWorkout!);

    final restored = _previousWorkout!;

    setState(() {
      _savedWorkout = restored;
      _canUndoWorkout = false;

      _warmupPlan = restored.exercises.where((e) {
        final id = int.tryParse(e.exerciseId) ?? 0;
        return id >= 1107;
      }).toList();

      _userPlan = restored.exercises.where((e) {
        final id = int.tryParse(e.exerciseId) ?? 0;
        return id < 1107;
      }).toList();

      _future = _loadExercises();
    });
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

  Future<void> _saveCurrentWorkout() async {
    final existing = LocalStorageService.getSavedWorkoutById(widget.workoutId);

    if (existing == null) return;
    _previousWorkout = existing;

    final updated = SavedWorkout(
      id: existing.id,
      createdAt: existing.createdAt,
      title: existing.title,
      durationMinutes: existing.durationMinutes,
      warmupOn: _warmupOn,
      exercises: [..._warmupPlan, ..._userPlan],
    );

    await LocalStorageService.saveGeneratedWorkout(updated);
  }

  Future<void> _addExercise() async {
    final selected = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AllExercisesScreen(multiSelect: true),
      ),
    );

    if (selected == null) return;

    final profile = LocalStorageService.getUserProfile();

    setState(() {
      for (final ex in selected) {
        final exists = _userPlan.any(
          (p) => p.exerciseId == ex['id'].toString(),
        );

        if (!exists) {
          _userPlan.add(
            WorkoutGenerator.buildPlannedExercise(
              profile: profile,
              exercise: ex,
            ),
          );
        }
      }
      _future = _loadExercises();
    });
  }

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
                      snap.data ?? (isLoading ? _lastExerciseItems : const []);
                  if (!isLoading && snap.hasData) {
                    // ✅ update cache only when we have fresh data
                    _lastExerciseItems = snap.data!;
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

                  final exerciseById = <String, Map<String, dynamic>>{
                    for (final ex in apiItems) _s(ex['id']): ex,
                  };

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WorkoutHeaderCard(
                          dayLabel: widget.dayLabel,
                          title: widget.title,
                          totalTimeText: widget.totalTimeText,
                          exercises: planItems,
                          muscleGroups: muscleGroupsForTitle(widget.title),
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 14),

                        WarmupSection(
                          warmupOn: _warmupOn,
                          warmupVisible: _warmupVisible,
                          warmupPlan: _warmupPlan,
                          exerciseById: exerciseById,

                          onToggleWarmup: _toggleWarmup,

                          onToggleVisible: () {
                            setState(() {
                              _warmupVisible = !_warmupVisible;
                            });
                          },

                          onEditWarmup: _editExerciseWarmup,

                          onDeleteWarmup: (p) async {
                            setState(() {
                              _warmupPlan.remove(p);
                            });

                            await _saveCurrentWorkout();
                          },
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Text(
                                "${planItems.length} exercises",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _addExercise,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF221FCB),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Add",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.add, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEAEAEA),
                        ),

                        const SizedBox(height: 10),

                        // ✅ Reorder + swipe-delete main list (user plan only)
                        ExerciseSection(
                          planItems: planItems,
                          exerciseById: exerciseById,

                          onDelete: (index) async {
                            setState(() {
                              _userPlan.removeAt(index);
                              _future = _loadExercises();
                            });

                            await _saveCurrentWorkout();
                          },

                          onEdit: _editExerciseWorkout,

                          onReorder: (oldIndex, newIndex) async {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }

                              final item = _userPlan.removeAt(oldIndex);
                              _userPlan.insert(newIndex, item);
                            });

                            await _saveCurrentWorkout();
                          },
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  );
                },
              ),
            ),

            WorkoutBottomActions(
              buttonText: buttonText,
              buttonColor: buttonColor,
              canUndoWorkout: _canUndoWorkout,
              onStartWorkout: _startWorkout,
              onGenerateWorkout: _generateNewWorkout,
              onUndoWorkout: _undoWorkoutGeneration,
            ),
          ],
        ),
      ),
    );
  }
}

String muscleGroupsForTitle(String title) {
  final t = title.toLowerCase();

  if (t.contains('push')) {
    return 'Chest • Shoulders • Triceps';
  }

  if (t.contains('pull')) {
    return 'Back • Rear Delts • Biceps';
  }

  if (t.contains('legs') || t.contains('lower')) {
    return 'Quads • Hamstrings • Glutes • Calves';
  }

  if (t.contains('upper')) {
    return 'Chest • Back • Shoulders • Arms';
  }

  if (t.contains('full')) {
    return 'Push • Pull • Legs • Core';
  }

  return '';
}
