import 'package:flutter/material.dart';

class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.userName});

  final String userName;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${getGreeting()}, $userName 👋",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
