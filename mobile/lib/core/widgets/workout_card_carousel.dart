import 'package:flutter/material.dart';
import 'package:mobile/core/models/day_plan.dart';
import 'package:mobile/core/widgets/workout_card.dart';

class WorkoutCarousel extends StatelessWidget {
  const WorkoutCarousel({
    super.key,
    required this.plans,
    required this.onPlanTap,
  });

  final List<DayPlan> plans;
  final ValueChanged<DayPlan> onPlanTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        itemCount: plans.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {

           final plan = plans[index];
          final isToday = index == 0;

          return GestureDetector(
            onTap: () => onPlanTap(plan),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: WorkoutCard(plan: plan, isToday: isToday),
            ),
          );
        },
      ),
    );
  }
}
