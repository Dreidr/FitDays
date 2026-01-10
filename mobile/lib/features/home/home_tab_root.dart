import 'package:flutter/material.dart';
import 'package:mobile/features/home/home_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      userName: "Idre",
      workoutStreak: 2,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      workoutDays: const ["Mon", "Wed", "Sat"],
    );
  }
}
