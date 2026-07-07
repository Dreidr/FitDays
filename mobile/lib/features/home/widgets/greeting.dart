import 'package:flutter/material.dart';
import 'package:mobile/features/workout/models/day_plan.dart';

class Greeting extends StatelessWidget {
  const Greeting({
    super.key,
    required this.userNameVN,
    required this.todayPlan,
  });

  final ValueNotifier<String> userNameVN;
  final DayPlan todayPlan;
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good morning 🌅";
    } else if (hour < 17) {
      return "Good afternoon 🌇";
    } else {
      return "Good evening 🏙️";
    }
  }

  int get dayOfYear {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);

    return now.difference(firstDay).inDays + 1;
  }

  String getWorkoutMessage() {
    String pick(List<String> messages) {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, 1, 1);

      final dayOfYear = now.difference(firstDay).inDays + 1;

      final seed = now.year * 1000 + dayOfYear;

      return messages[seed % messages.length];
    }

    switch (todayPlan.title.toLowerCase()) {
      case "push":
        return pick([
          "Time to push your limits today 💪",
          "Chest, shoulders and triceps are waiting 🔥",
          "Every rep makes you stronger 💥",
        ]);

      case "pull":
        return pick([
          "Build a stronger back today 🔥",
          "Pull with power. Finish with pride 💪",
          "Strong backs build strong bodies 🏋️",
        ]);

      case "legs":
        return pick([
          "Leg day. You won't regret it later 🦵",
          "Strong legs. Strong foundation 🏋️",
          "Today's squats are tomorrow's strength 💥",
        ]);

      case "upper body":
        return pick([
          "Upper body day. Let's get stronger 💪",
          "Build strength one rep at a time 🔥",
          "Push your upper body to the next level 🚀",
        ]);

      case "lower body":
        return pick([
          "Strong legs build a strong foundation 🏋️",
          "Power starts from the ground up 🦵",
          "Lower body. Bigger gains 💥",
        ]);

      case "full body":
        return pick([
          "A full body challenge awaits today ⚡",
          "Train every muscle today 💪",
          "Full body. Full effort. Let's go 🔥",
        ]);

      case "hiit":
        return pick([
          "Give it everything you've got today ❤️",
          "Short workout. Big results ⚡",
          "Push hard. Recover stronger 🔥",
        ]);

      case "steady cardio":
        return pick([
          "Every step builds endurance 🏃",
          "Consistency beats intensity ❤️",
          "Keep moving. Keep improving 🚶",
        ]);

      case "core & conditioning":
        return pick([
          "Strength starts from your core 💥",
          "Build a stronger core today 💪",
          "Core first. Everything else follows 🔥",
        ]);

      case "full body circuit":
        return pick([
          "Circuit time. Keep moving! ⚡",
          "No stopping today 💪",
          "One exercise after another. You got this 🔥",
        ]);

      case "stretching":
        return pick([
          "Move freely. Recover fully 🌿",
          "Flexibility is strength too 🤸",
          "Take care of your body today 💚",
        ]);

      case "mobility":
        return pick([
          "Improve your movement today 🤸",
          "Move better. Feel better 🌿",
          "Healthy joints. Better workouts 💪",
        ]);

      case "recovery":
        return pick([
          "Recovery is where progress happens 🌱",
          "Give your body time to rebuild 💙",
          "Rest today. Come back stronger 💪",
        ]);

      case "yoga flow":
        return pick([
          "Breathe, stretch and reset 🧘",
          "Find your balance today 🌿",
          "Move with purpose today ✨",
        ]);

      case "balance training":
        return pick([
          "Build better balance today ⚖️",
          "Control is strength 💪",
          "Small movements. Big improvements 🌿",
        ]);

      case "functional movement":
        return pick([
          "Train for everyday strength 💪",
          "Move better every day 🚶",
          "Real-life strength starts here 🔥",
        ]);

      case "mobility & stability":
        return pick([
          "Better movement starts today 🌿",
          "Strong and stable wins every time 💪",
          "Mobility today. Strength tomorrow 🔥",
        ]);

      default:
        return pick([
          "Let's make today count 💪",
          "Every workout moves you forward 🚀",
          "Small progress is still progress 🌟",
        ]);
    }
  }

  String getMotivation() {
    final hour = DateTime.now().hour;

    // 💤 Rest day
    if (!todayPlan.isWorkoutDay) {
      if (hour < 12) {
        return "Today is your recovery day. Rest is part of the progress 🌿";
      } else if (hour < 17) {
        return "Recover well today so you come back stronger 💙";
      } else {
        return "Recharge tonight. Tomorrow is another opportunity 🌙";
      }
    }

    return getWorkoutMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: userNameVN,
          builder: (_, name, _) {
            return Text(
              "${getGreeting()}, $name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            );
          },
        ),
        const SizedBox(height: 6),

        Text(
          getMotivation(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
