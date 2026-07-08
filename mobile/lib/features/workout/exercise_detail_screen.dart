import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:mobile/core/models/exercise_set.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/features/workout/widgets/show_set_picker.dart';
import 'package:mobile/features/workout/models/planned_exercise.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.plannedExercise,
    this.onReplace,
  });

  final Map<String, dynamic> exercise;
  final PlannedExercise? plannedExercise;

  final Future<void> Function()? onReplace;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late List<ExerciseSet> workoutSets;
  late VideoPlayerController _controller;
  bool _ready = false;

  String _s(dynamic v) => (v ?? '').toString();

  List<String> _list(dynamic v) =>
      (v is List) ? v.map((e) => e.toString()).toList() : const [];

  Future<void> _editSet(int index) async {
    final updated = await showSetPicker(
      context: context,
      exerciseName: widget.exercise['name'],
      initial: workoutSets[index],
    );

    if (updated != null) {
      setState(() {
        workoutSets[index] = updated;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final id = widget.exercise['id'];

    _controller = VideoPlayerController.asset('assets/videos/$id.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();

        if (mounted) {
          setState(() {
            _ready = true;
          });
        }
      });

    if (widget.plannedExercise != null) {
      workoutSets = List.generate(
        widget.plannedExercise!.sets,
        (_) => ExerciseSet(
          reps: widget.plannedExercise!.reps,
          weightKg: widget.plannedExercise!.weightKg,
        ),
      );
    } else {
      workoutSets = [ExerciseSet(reps: 10, weightKg: 80)];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    final name = _s(ex['name']);

    final description = _s(ex['description']);

    final instructions = _list(ex['instructions']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,

        title: const Text(
          "Exercise Detail",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          if (widget.onReplace != null)
            IconButton(
              icon: const Icon(Icons.change_circle_outlined),
              color: Colors.black87,
              onPressed: widget.onReplace,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _ready
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),

            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (widget.plannedExercise != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Workout Setup",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 2),

                Text(
                  "${workoutSets.length} ${workoutSets.length == 1 ? "Set" : "Sets"}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Column(
              children: [
                ...List.generate(workoutSets.length, (index) {
                  final set = workoutSets[index];

                  final weightText = set.weightKg == null
                      ? null
                      : (set.weightKg! == set.weightKg!.roundToDouble()
                            ? set.weightKg!.toStringAsFixed(0)
                            : set.weightKg!.toStringAsFixed(1));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Slidable(
                      key: ValueKey(index),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              setState(() {
                                if (workoutSets.length > 1) {
                                  workoutSets.removeAt(index);
                                }
                              });
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_outline,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _editSet(index),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 200, // adjust between 180–240
                            child: set.weightKg == null
                                ? Center(
                                    child: Text(
                                      "${set.reps} reps",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 220,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            "${set.reps} reps",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              "×",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black38,
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            "$weightText kg",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Add Set"),
                  onTap: () {
                    setState(() {
                      if (workoutSets.isNotEmpty) {
                        workoutSets.add(workoutSets.last.copy());
                      } else {
                        workoutSets.add(ExerciseSet(reps: 10));
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],

          const Text(
            "Instructions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          if (instructions.isEmpty) const Text("No instructions available."),

          for (int i = 0; i < instructions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${i + 1}. ",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(child: Text(instructions[i])),
                ],
              ),
            ),
          const SizedBox(height: 24),

          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "Muscle Illustration",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
