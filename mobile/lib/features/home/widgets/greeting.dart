import 'package:flutter/material.dart';

class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.userNameVN});

  final ValueNotifier<String> userNameVN;

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

  String getMotivation() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Let’s start the day strong 💪";
    } else if (hour < 17) {
      return "Keep the momentum going 🚀";
    } else if (hour < 21) {
      return "Finish the day proud 🏁";
    } else {
      return "Small steps still count 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
 return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ValueListenableBuilder<String>(
      valueListenable: userNameVN,
      builder: (_, name, __) {
        return Text(
          "${getGreeting()}, $name 👋",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
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
