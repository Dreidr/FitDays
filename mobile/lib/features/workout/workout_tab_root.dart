import 'package:flutter/material.dart';

class WorkoutTabRoot extends StatelessWidget {
  const WorkoutTabRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(child: Text("Workout tab root")),
      ),
    );
  }
}
