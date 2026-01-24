import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/features/workout/services/exercise_db_api.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Map<String, dynamic> exercise;

  String _s(dynamic v) => (v ?? '').toString();
  List<String> _list(dynamic v) =>
      (v is List) ? v.map((e) => e.toString()).toList() : const [];

  @override
  Widget build(BuildContext context) {
    final id = _s(exercise['id']);
    final name = _s(exercise['name']);
    final bodyPart = _s(exercise['bodyPart']);
    final target = _s(exercise['target']);
    final equipment = _s(exercise['equipment']);
    final secondary = _list(exercise['secondaryMuscles']);
    final instructions = _list(exercise['instructions']);

    return Scaffold(
      appBar: AppBar(title: Text(name.isEmpty ? 'Exercise' : name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: id.isEmpty
                  ? Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Text('No animation'),
                    )
                  : FutureBuilder<Uint8List>(
                      future: ExerciseDbApi.fetchImageBytes(
                        exerciseId: id,
                        resolution: '720',
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snap.hasError || !snap.hasData) {
                          return Container(
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Text('Failed to load animation'),
                          );
                        }
                        return Image.memory(snap.data!, fit: BoxFit.cover);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (bodyPart.isNotEmpty) _Chip('Body: $bodyPart'),
              if (target.isNotEmpty) _Chip('Target: $target'),
              if (equipment.isNotEmpty) _Chip('Equipment: $equipment'),
            ],
          ),
          const SizedBox(height: 16),
          if (secondary.isNotEmpty) ...[
            Text(
              'Secondary muscles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secondary.map((m) => _Chip(m)).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          if (instructions.isEmpty)
            const Text('No instructions available.')
          else
            for (int i = 0; i < instructions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Expanded(child: Text(instructions[i])),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
