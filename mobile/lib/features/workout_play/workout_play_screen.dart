import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'dart:typed_data';
import 'package:mobile/features/workout/services/exercise_db_api.dart';

class WorkoutPlayScreen extends StatefulWidget {
  const WorkoutPlayScreen({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.plan,
    required this.exercises,
  });

  final String dayLabel;
  final String title;
  final List<PlannedExercise> plan;
  final List<Map<String, dynamic>> exercises;

  @override
  State<WorkoutPlayScreen> createState() => _WorkoutPlayScreenState();
}

class _WorkoutPlayScreenState extends State<WorkoutPlayScreen> {
  int _exerciseIndex = 0;
  int _setIndex = 1;

  bool _isResting = false;
  int _restLeft = 0;
  Timer? _timer;
  

  final Map<String, Future<Uint8List>> _gifFutureCache = {};

  String _currentMediaKey = "";

  static const int _defaultRestSeconds = 25;
  static const int _minRestSeconds = 20;
  static const int _maxRestSeconds = 60;

  void _changeRestBy(int delta) {
    if (!_isResting) return;
    setState(() {
      _restLeft = (_restLeft + delta).clamp(_minRestSeconds, _maxRestSeconds);
    });
  }

  Future<Uint8List>? _mediaFutureFor(String exerciseId) {
    if (exerciseId.isEmpty) return null;

    return _gifFutureCache.putIfAbsent(
      exerciseId,
      () => ExerciseDbApi.fetchImageBytes(
        exerciseId: exerciseId,
        resolution: '720',
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get _ex => widget.exercises[_exerciseIndex];
  PlannedExercise get _planned => widget.plan[_exerciseIndex];

  String _s(dynamic v) => (v ?? '').toString();

  void _startRest([int seconds = _defaultRestSeconds]) {
    _timer?.cancel();
    setState(() {
      _isResting = true;
      _restLeft = seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_restLeft <= 1) {
        t.cancel();
        setState(() {
          _isResting = false;
          _restLeft = 0;
        });
        return;
      }

      setState(() => _restLeft--);
    });
  }

  void _completeSet() {
    if (_isResting) return;

    // ✅ More sets remaining -> increment NOW, then rest
    if (_setIndex < _planned.sets) {
      setState(() => _setIndex++);
      _startRest();
      return;
    }

    // ✅ Exercise finished -> go next exercise
    if (_exerciseIndex < widget.plan.length - 1) {
      setState(() {
        _exerciseIndex++;
        _setIndex = 1;
        _currentMediaKey = "ex_${widget.plan[_exerciseIndex].exerciseId}";
      });
      _startRest(20);
      return;
    }

    _finishWorkout();
  }

  void _finishWorkout() {
    _timer?.cancel();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Workout complete! 🎉"),
        content: const Text(
          "Great job! Next we’ll show a workout summary here.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit play screen
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _restLeft = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentMediaKey = "ex_${widget.plan.first.exerciseId}";
  }

  @override
  Widget build(BuildContext context) {
    final name = _s(_ex['name']);
    final target = _s(_ex['target']);
    final weight = _planned.weightKg;

    return Scaffold(
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
                                child: Builder(
                                  key: ValueKey(_currentMediaKey),
                                  builder: (context) {
                                    final id = _planned.exerciseId;
                                    final future = _mediaFutureFor(id);

                                    if (id.isEmpty || future == null) {
                                      return Container(
                                        color: Colors.black12,
                                        alignment: Alignment.center,
                                        child: const Text('No animation'),
                                      );
                                    }

                                    return FutureBuilder<Uint8List>(
                                      future: future,
                                      builder: (context, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snap.hasError || !snap.hasData) {
                                          return Container(
                                            color: Colors.black12,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'Failed to load animation',
                                            ),
                                          );
                                        }
                                        return Image.memory(
                                          snap.data!,
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Progress
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Exercise ${_exerciseIndex + 1} / ${widget.plan.length}",
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
                      onPressed: _isResting ? null : _completeSet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4442D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _isResting ? "Resting..." : "Complete set",
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
            Positioned(
              left: 18,
              right: 18,
              top: 8,
              child: IgnorePointer(
                ignoring: !_isResting,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  offset: _isResting ? Offset.zero : const Offset(0, -0.35),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _isResting ? 1 : 0,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Color(0xFF4442D9),
                              size: 20,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Rest: $_restLeft sec",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            // ➖
                            _TinyIconButton(
                              icon: Icons.remove,
                              onTap: () => _changeRestBy(-5),
                            ),
                            const SizedBox(width: 6),

                            // ➕
                            _TinyIconButton(
                              icon: Icons.add,
                              onTap: () => _changeRestBy(5),
                            ),
                            const SizedBox(width: 8),

                            TextButton(
                              onPressed: _skipRest,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                              ),
                              child: const Text("Skip"),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}
