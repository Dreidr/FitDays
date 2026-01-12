import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_decorations.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.dayLabel,
    required this.title,
    required this.totalTimeText,
  });

  final String dayLabel;
  final String title;
  final String totalTimeText;

  @override
  Widget build(BuildContext context) {
    // UI-only mock data (replace later with real plan data)
    final exercises = <_ExerciseRowData>[
      const _ExerciseRowData("DB Chest Flyes", "3 sets x 12 reps x 20kg"),
      const _ExerciseRowData("Landmine twists", "3 sets x 12 reps x 20kg"),
      const _ExerciseRowData("DB press", "3 sets x 12 reps x 20kg"),
      const _ExerciseRowData("Skull Crushers", "3 sets x 12 reps x 20kg"),
      const _ExerciseRowData("Incline DB press", "3 sets x 12 reps x 20kg"),
      const _ExerciseRowData("Plank", "3 sets x 12 reps"),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(
                      dayLabel: dayLabel,
                      title: title,
                      exerciseCount: exercises.length,
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Total time: $totalTimeText",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Exercise list
                    ...exercises.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ExerciseRow(
                            name: e.name,
                            meta: e.meta,
                            onMore: () {},
                            onReorder: () {},
                          ),
                        )),

                    const SizedBox(height: 6),

                    // Muscle groups / equipment card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card(context),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Muscle groups",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Primary: ",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                TextSpan(text: "Back, Chest"),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Secondary: ",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                TextSpan(text: "Tricep"),
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            "Equipments",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("• Leverage machine"),
                          Text("• Barbell"),
                          Text("• Dumbbell"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky bottom actions
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          "Regenerate",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4442D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, color: Colors.black87),
                        label: const Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                child: Container(
                  width: 56,
                  color: Colors.white24,
                ),
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
    required this.name,
    required this.meta,
    required this.onMore,
    required this.onReorder,
  });

  final String name;
  final String meta;
  final VoidCallback onMore;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // image placeholder box
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26),
            ),
            child: const Icon(Icons.image_outlined, color: Colors.black54),
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
    );
  }
}

class _ExerciseRowData {
  const _ExerciseRowData(this.name, this.meta);
  final String name;
  final String meta;
}


