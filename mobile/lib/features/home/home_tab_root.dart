import 'package:flutter/material.dart';
import 'package:mobile/features/home/home_screen.dart';

class HomeTabRoot extends StatelessWidget {
  const HomeTabRoot({
    super.key,
    required this.userNameVN,
    required this.workoutStreak,
    required this.startDate,
    required this.workoutDays,
  });

  final ValueNotifier<String> userNameVN;
  final int workoutStreak;
  final DateTime startDate;
  final List<String> workoutDays;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => HomeScreen(
          userNameVN: userNameVN,
          workoutStreak: workoutStreak,
          startDate: startDate,
          workoutDays: workoutDays,
        ),
      ),
    );
  }
}
