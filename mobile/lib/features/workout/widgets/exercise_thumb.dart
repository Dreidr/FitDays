import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/features/workout/services/exercise_db_api.dart';

class ExerciseThumb extends StatefulWidget {
  const ExerciseThumb({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  State<ExerciseThumb> createState() => _ExerciseThumbState();
}

class _ExerciseThumbState extends State<ExerciseThumb> {
  late final Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = ExerciseDbApi.fetchImageBytes(
      exerciseId: widget.exerciseId,
      resolution: '180',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return const Icon(Icons.broken_image, color: Colors.black54);
        }
        return Image.memory(
          snap.data!,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
