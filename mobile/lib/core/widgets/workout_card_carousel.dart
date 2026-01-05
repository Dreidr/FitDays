import 'package:flutter/material.dart';
import 'package:mobile/core/models/day_plan.dart';
import 'package:mobile/core/widgets/workout_card.dart';

class WorkoutCarousel extends StatelessWidget {
  const WorkoutCarousel({super.key, required this.plans});

  final List<DayPlan> plans;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        itemCount: plans.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: WorkoutCard(plan: plans[index], isToday: index == 0),
          );
        },
      ),
    );
  }
}
