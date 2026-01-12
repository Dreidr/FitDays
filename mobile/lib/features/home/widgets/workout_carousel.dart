import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/day_plan.dart';
import 'package:mobile/features/home/widgets/workout_card.dart';

class WorkoutCarousel extends StatelessWidget {
  const WorkoutCarousel({
    super.key,
    required this.plans,
    required this.onPlanTap,
    this.extraCard,     // ✅ new
    this.onExtraTap,    // ✅ new
  });

  final List<DayPlan> plans;
  final ValueChanged<DayPlan> onPlanTap;

  final Widget? extraCard;
  final VoidCallback? onExtraTap;

  @override
  Widget build(BuildContext context) {
    final itemCount = plans.length + (extraCard == null ? 0 : 1);

    return SizedBox(
      height: 190,
      child: PageView.builder(
        itemCount: itemCount,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final isExtra = extraCard != null && index == plans.length;

          if (isExtra) {
            return GestureDetector(
              onTap: onExtraTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: extraCard!,
              ),
            );
          }

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
