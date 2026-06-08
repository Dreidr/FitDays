import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  final Map<String, dynamic> exercise;

  @override
  State<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState
    extends State<ExerciseDetailScreen> {
  late VideoPlayerController _controller;
  bool _ready = false;

  String _s(dynamic v) => (v ?? '').toString();

  List<String> _list(dynamic v) =>
      (v is List)
          ? v.map((e) => e.toString()).toList()
          : const [];

  @override
  void initState() {
    super.initState();

    final id = widget.exercise['id'];

    _controller = VideoPlayerController.asset(
      'assets/videos/$id.mp4',
    )..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();

        if (mounted) {
          setState(() {
            _ready = true;
          });
        }
      });
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
    final bodyPart = _s(ex['bodyPart']);
    final target = _s(ex['target']);
    final equipment = _s(ex['equipment']);
    final difficulty = _s(ex['difficulty']);
    final description = _s(ex['description']);

    final secondary = _list(ex['secondaryMuscles']);
    final instructions = _list(ex['instructions']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          name.isEmpty ? 'Exercise' : name,
        ),
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
              child: SizedBox(
                height: 300,
                child: _ready
                    ? AspectRatio(
                        aspectRatio:
                            _controller.value.aspectRatio,
                        child: VideoPlayer(
                          _controller,
                        ),
                      )
                    : const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (bodyPart.isNotEmpty)
                _Chip("Body: $bodyPart"),

              if (target.isNotEmpty)
                _Chip("Target: $target"),

              if (equipment.isNotEmpty)
                _Chip("Equipment: $equipment"),

              if (difficulty.isNotEmpty)
                _Chip("Difficulty: $difficulty"),
            ],
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(description),
          ],

          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 20),

            const Text(
              "Secondary Muscles",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secondary
                  .map((e) => _Chip(e))
                  .toList(),
            ),
          ],

          const SizedBox(height: 20),

          const Text(
            "Instructions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          if (instructions.isEmpty)
            const Text(
              "No instructions available.",
            ),

          for (int i = 0;
              i < instructions.length;
              i++)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "${i + 1}. ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      instructions[i],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}