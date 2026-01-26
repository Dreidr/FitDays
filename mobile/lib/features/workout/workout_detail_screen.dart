import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';
import 'package:mobile/features/workout/exercise_detail_screen.dart';
import 'package:mobile/features/workout/widgets/exercise_thumb.dart';
import 'package:mobile/features/workout/services/local_exercise_repo.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.totalTimeText,
    required this.plan, // ✅ new
  });

  final String dayLabel;
  final String title;
  final String totalTimeText;
  final List<PlannedExercise> plan;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  bool _warmupOn = true;

  @override
  void initState() {
    super.initState();
    _future = _loadExercises();
  }

  // ✅ Replace these warmup IDs with ones that exist in your local JSON
  List<PlannedExercise> _warmupPlan() {
    return const [
      PlannedExercise(
        exerciseId: "Jumping_Jacks",
        sets: 1,
        reps: 30,
        weightKg: 0,
      ),
      PlannedExercise(
        exerciseId: "Arm_Circles",
        sets: 1,
        reps: 20,
        weightKg: 0,
      ),
    ];
  }

  List<PlannedExercise> get _activePlan {
    if (!_warmupOn) return widget.plan;
    return [..._warmupPlan(), ...widget.plan];
  }

  Future<List<Map<String, dynamic>>> _loadExercises() {
    final ids = _activePlan.map((e) => e.exerciseId).toList();
    return LocalExerciseRepo.fetchExercisesByIds(ids);
  }

  void _toggleWarmup(bool v) {
    setState(() {
      _warmupOn = v;
      _future = _loadExercises(); // ✅ reload list based on toggle
    });
  }

  void _startWorkout() {
    // ✅ MVP: just confirm start (later navigate to WorkoutSessionScreen)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _warmupOn
              ? "Starting workout (with warm-up)..."
              : "Starting workout...",
        ),
      ),
    );

    // TODO later:
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => WorkoutSessionScreen(sessionPlan: _activePlan),
    // ));
  }

  String _s(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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

                  final apiItems = snap.data ?? [];
                  final count = apiItems.length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderCard(
                          dayLabel: widget.dayLabel,
                          title: widget.title,
                          exerciseCount: count,
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
                        const SizedBox(height: 10),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
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
                              Switch(
                                value: _warmupOn,
                                onChanged: _toggleWarmup,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ API-driven exercise list
                        ...List.generate(count, (i) {
                          final ex = apiItems[i];
                          final planned = _activePlan[i];

                          final id = _s(ex['id']);
                          final name = _s(ex['name']);
                          final target = _s(ex['target']);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ExerciseRow(
                              exerciseId: id, // ✅ new
                              name: name.isEmpty ? "Exercise" : name,
                              meta: "${planned.metaText()} • Target: $target",
                              onMore: () {},
                              onReorder: () {},
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExerciseDetailScreen(exercise: ex),
                                  ),
                                );
                              },
                            ),
                          );
                        }),

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
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _startWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4442D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Start workout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
            const Color(0xFF4442D9).withOpacity(0.85),
            const Color(0xFF2F2ECF).withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4442D9).withOpacity(0.35),
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
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => ClipRRect(
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
    required this.onReorder,
    required this.onTap,
  });

  final String exerciseId;
  final String name;
  final String meta;
  final VoidCallback onMore;
  final VoidCallback onReorder;
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
            IconButton(
              onPressed: onReorder,
              icon: const Icon(Icons.drag_handle, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
