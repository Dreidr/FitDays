import 'package:mobile/core/enums/workout_type.dart';

class WorkoutInfo {
  final String title;
  final String subtitle;

  const WorkoutInfo({required this.title, required this.subtitle});
}

WorkoutInfo getWorkoutInfo(WorkoutType type) {
  switch (type) {
    case WorkoutType.push:
      return const WorkoutInfo(
        title: "Push Day 💪",
        subtitle: "Chest • Shoulders • Triceps",
      );

    case WorkoutType.pull:
      return const WorkoutInfo(title: "Pull Day 🔥", subtitle: "Back • Biceps");

    case WorkoutType.legs:
      return const WorkoutInfo(
        title: "Leg Day 🦵",
        subtitle: "Quads • Hamstrings • Glutes",
      );

    case WorkoutType.upperBody:
      return const WorkoutInfo(
        title: "Upper Body 💥",
        subtitle: "Chest • Back • Shoulders • Arms",
      );

    case WorkoutType.lowerBody:
      return const WorkoutInfo(
        title: "Lower Body 🏋️",
        subtitle: "Quads • Hamstrings • Glutes",
      );

    case WorkoutType.fullBody:
      return const WorkoutInfo(
        title: "Full Body ⚡",
        subtitle: "Full Body Strength",
      );

    case WorkoutType.hiit:
      return const WorkoutInfo(
        title: "HIIT ❤️",
        subtitle: "High Intensity Intervals",
      );

    case WorkoutType.steadyCardio:
      return const WorkoutInfo(
        title: "Steady Cardio 🏃",
        subtitle: "Endurance Training",
      );

    case WorkoutType.fullBodyCircuit:
      return const WorkoutInfo(
        title: "Full Body Circuit ⚡",
        subtitle: "Strength • Cardio",
      );

    case WorkoutType.stretching:
      return const WorkoutInfo(
        title: "Stretching 🌿",
        subtitle: "Flexibility & Recovery",
      );

    case WorkoutType.mobility:
      return const WorkoutInfo(
        title: "Mobility 🤸",
        subtitle: "Joint Health & Movement",
      );

    case WorkoutType.recovery:
      return const WorkoutInfo(
        title: "Recovery 🌱",
        subtitle: "Rest & Restore",
      );

    case WorkoutType.yogaFlow:
      return const WorkoutInfo(
        title: "Yoga Flow 🧘",
        subtitle: "Mind • Body • Flexibility",
      );

    case WorkoutType.balanceTraining:
      return const WorkoutInfo(
        title: "Balance Training ⚖️",
        subtitle: "Stability & Coordination",
      );

    case WorkoutType.functionalMovement:
      return const WorkoutInfo(
        title: "Functional Movement 🚶",
        subtitle: "Everyday Strength",
      );

    case WorkoutType.mobilityStability:
      return const WorkoutInfo(
        title: "Mobility & Stability 🌿",
        subtitle: "Movement • Control",
      );

    case WorkoutType.rest:
      return const WorkoutInfo(
        title: "Recovery Day 🌿",
        subtitle: "Rest • Recover • Recharge",
      );

    default:
      return const WorkoutInfo(title: "Workout 💪", subtitle: "");
  }
}
