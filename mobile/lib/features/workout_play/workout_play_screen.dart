import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';

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
  bool _advanceSetAfterRest = false;

  // ✅ MVP rest seconds (later you can compute per exercise / per set)
  static const int _defaultRestSeconds = 45;

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

          if (_advanceSetAfterRest) {
            _advanceSetAfterRest = false;
            _setIndex++;
          }
        });
        return;
      }

      setState(() => _restLeft--);
    });
  }

  void _completeSet() {
    if (_isResting) return;

    // More sets remaining -> rest first, then advance set after rest
    if (_setIndex < _planned.sets) {
      _advanceSetAfterRest = true;
      _startRest();
      return;
    }

    // Exercise finished -> go next exercise (rest optional)
    if (_exerciseIndex < widget.plan.length - 1) {
      setState(() {
        _exerciseIndex++;
        _setIndex = 1;
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              target.isEmpty ? "" : "Target: $target",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 22),

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
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    "Set $_setIndex / ${_planned.sets}",
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

            const Spacer(),

            if (_isResting) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4442D9).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFF4442D9)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Rest: $_restLeft sec",
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton(onPressed: _skipRest, child: const Text("Skip")),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _completeSet,
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
    );
  }
}
