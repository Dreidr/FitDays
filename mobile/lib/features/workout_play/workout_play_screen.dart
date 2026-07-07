import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/features/workout/workout_complete_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/workout_play/models/active_workout_session.dart';
import 'package:video_player/video_player.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';
import 'package:mobile/features/workout/widgets/set_completion_screen.dart';

class WorkoutPlayScreen extends StatefulWidget {
  const WorkoutPlayScreen({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.exercises,
    required this.warmupCount,
    required this.workoutId,
  });

  final String dayLabel;
  final String title;
  final List<PlannedExercise> exercises;
  final int warmupCount;
  final String workoutId;

  @override
  State<WorkoutPlayScreen> createState() => _WorkoutPlayScreenState();
}

class _WorkoutPlayScreenState extends State<WorkoutPlayScreen> {
  Map<String, dynamic>? _exerciseData;
  Future<void> _loadExerciseData() async {
    _exerciseData = await LocalExerciseRepo.getById(_planned.exerciseId);

    if (mounted) {
      setState(() {});
    }
  }

  VideoPlayerController? _videoController;
  Future<void> _loadVideo(String exerciseId) async {
    final oldController = _videoController;

    _videoController = null;

    if (mounted) {
      setState(() {});
    }

    await oldController?.dispose();

    final controller = VideoPlayerController.asset(
      'assets/videos/$exerciseId.mp4',
    );

    _videoController = controller;

    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Timer? _workoutTimer;
  int _elapsedSeconds = 0;

  // Optional but nice: stable id for this run
  late final String _workoutId;

  int _exerciseIndex = 0;
  int _setIndex = 1;

  bool _isResting = false;
  int _restLeft = 0;
  Timer? _timer;

  int get _warmupCount => widget.warmupCount;

  int get _workoutIndex => _exerciseIndex - _warmupCount;

  int get _workoutTotal => widget.exercises.length - _warmupCount;

  PlannedExercise get _planned => widget.exercises[_exerciseIndex];

  static const int _defaultRestSeconds = 25;
  static const int _minRestSeconds = 20;
  static const int _maxRestSeconds = 60;

  void _changeRestBy(int delta) async {
    if (!_isResting) return;
    setState(() {
      _restLeft = (_restLeft + delta).clamp(_minRestSeconds, _maxRestSeconds);
    });
    await _persistSession();
  }

  void _resumeRestTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;

      if (_restLeft <= 1) {
        t.cancel();
        setState(() {
          _isResting = false;
          _restLeft = 0;
        });
        await _persistSession();
        return;
      }

      setState(() => _restLeft--);
      await _persistSession();
    });
  }

  Future<void> _persistSession() async {
    final session = ActiveWorkoutSession(
      workoutId: _workoutId,
      dayLabel: widget.dayLabel,
      title: widget.title,
      exerciseIndex: _exerciseIndex,
      setIndex: _setIndex,
      elapsedSeconds: _elapsedSeconds,
      isResting: _isResting,
      restLeft: _restLeft,
      warmupCount: widget.warmupCount,
      updatedAt: DateTime.now(),
    );

    await LocalStorageService.saveActiveWorkoutSession(session);
  }

  void _restoreFromSavedSession() {
    final saved = LocalStorageService.getActiveWorkoutSession();
    if (saved == null) return;
    if (saved.workoutId != widget.workoutId) return;

    _exerciseIndex = saved.exerciseIndex.clamp(0, widget.exercises.length - 1);
    _setIndex = saved.setIndex < 1 ? 1 : saved.setIndex;
    _elapsedSeconds = saved.elapsedSeconds;
    _isResting = saved.isResting;
    _restLeft = saved.restLeft;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workoutTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  String s(dynamic v) => (v ?? '').toString();

  void _startRest([int seconds = _defaultRestSeconds]) async {
    _timer?.cancel();

    setState(() {
      _isResting = true;
      _restLeft = seconds;
    });

    await _persistSession();
    _resumeRestTimer();
  }

  void _logSet() async {
    if (_isResting) return;

    if (_setIndex < _planned.sets) {
      setState(() => _setIndex++);

      await _persistSession();
      _startRest();
      return;
    }

    final currentExercise = widget.exercises[_exerciseIndex];

    final hasNext = _exerciseIndex < widget.exercises.length - 1;

    final nextExercise = hasNext ? widget.exercises[_exerciseIndex + 1] : null;

    final currentExerciseData = await LocalExerciseRepo.getById(
      currentExercise.exerciseId,
    );

    final nextExerciseData = nextExercise == null
        ? null
        : await LocalExerciseRepo.getById(nextExercise.exerciseId);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetCompletionScreen(
          completedExercise: currentExercise,
          nextExercise: nextExercise,
          completedName: currentExerciseData?['name'] ?? 'Exercise',
          nextName: nextExerciseData?['name'],
        ),
      ),
    );

    if (hasNext) {
      setState(() {
        _exerciseIndex++;
        _setIndex = 1;
      });

      await _loadExerciseData();

      await _loadVideo(widget.exercises[_exerciseIndex].exerciseId);

      await _persistSession();

      return;
    }

    _finishWorkout();
  }

  void _finishWorkout() async {
    _timer?.cancel();
    _workoutTimer?.cancel();

    await LocalStorageService.clearActiveWorkoutSession();
    await LocalStorageService.markWorkoutCompletedForDay(DateTime.now());

    if (!mounted) return;

    final plannedExercises = widget.exercises.length;
    final completedExercises = _exerciseIndex + 1;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutCompleteScreen(
          workoutId: _workoutId,
          title: widget.title,
          plannedExercises: plannedExercises,
          completedExercises: completedExercises,
          durationSeconds: _elapsedSeconds,
          estimatedCalories: 0,
        ),
      ),
    );
  }

  void _skipRest() async {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _restLeft = 0;
    });
    await _persistSession();
  }

  final completedDates = LocalStorageService.getCompletedDays()
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet();

  @override
  void initState() {
    super.initState();
    _loadExerciseData();

    _workoutId = widget.workoutId;

    _restoreFromSavedSession();

    _loadVideo(widget.exercises[_exerciseIndex].exerciseId);

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
      await _persistSession();
    });

    if (_isResting && _restLeft > 0) {
      _resumeRestTimer();
    } else {
      _isResting = false;
      _restLeft = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _exerciseData?['name']?.toString() ?? "Exercise";
    final target = "";
    final weight = _planned.weightKg;
    final instructions =
        (_exerciseData?['instructions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await _persistSession();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  18,
                ), // ✅ room for toast
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ scrollable content only
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.dayLabel,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              name.isEmpty ? "Exercise" : name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              target.isEmpty ? "" : "Target: $target",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ✅ Exercise animation panel
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, anim) {
                                    final fade = FadeTransition(
                                      opacity: anim,
                                      child: child,
                                    );
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.04, 0),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: fade,
                                    );
                                  },
                                  child:
                                      _videoController != null &&
                                          _videoController!.value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio: _videoController!
                                              .value
                                              .aspectRatio,
                                          child: VideoPlayer(_videoController!),
                                        )
                                      : Container(
                                          color: Colors.black12,
                                          alignment: Alignment.center,
                                          child:
                                              const CircularProgressIndicator(),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Progress
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _exerciseIndex < _warmupCount
                                          ? "Warm-up ${_exerciseIndex + 1} / $_warmupCount"
                                          : "Exercise ${_workoutIndex + 1} / $_workoutTotal",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Set $_setIndex / ${_planned.sets}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Sets/Reps card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${_planned.reps} reps",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    (weight != null && weight > 0)
                                        ? "${weight.toStringAsFixed(1)} kg"
                                        : "Bodyweight",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            if (instructions.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Instructions",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    ...instructions.asMap().entries.map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${entry.key + 1}. ",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.4,
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

                            const SizedBox(
                              height: 18,
                            ), // ✅ space before bottom button
                          ],
                        ),
                      ),
                    ),

                    // ✅ fixed bottom button (NOT inside scroll view)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isResting ? null : _logSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4442D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isResting ? "Resting..." : "Log Set",
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

              // ✅ Rest toast overlay (top)
              // ✅ Big Rest Overlay (blur + modal card)
              if (_isResting)
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _isResting ? 1 : 0,
                    child: Stack(
                      children: [
                        // blur background + dim
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ),
                        ),

                        // centered card
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(width: 10),
                                  Text(
                                    "Rest",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // +/- buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _BigRoundButton(
                                    icon: Icons.remove,
                                    onTap: () => _changeRestBy(-5),
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 24),

                                  // BIG timer
                                  Text(
                                    "$_restLeft",
                                    style: const TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: Color.fromARGB(255, 244, 124, 38),
                                    ),
                                  ),
                                  const SizedBox(width: 24),

                                  _BigRoundButton(
                                    icon: Icons.add,
                                    onTap: () => _changeRestBy(5),
                                    color: Colors.black87,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // Skip
                              TextButton(
                                onPressed: _skipRest,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                ),
                                child: const Text(
                                  "Skip Rest",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigRoundButton extends StatelessWidget {
  const _BigRoundButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.black,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }
}
