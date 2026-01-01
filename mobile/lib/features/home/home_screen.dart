import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/top_row.dart';
import 'package:mobile/core/widgets/greeting_calendar.dart';
import 'package:mobile/core/widgets/workout_card.dart';
import 'package:mobile/core/widgets/quick_actions.dart';
import 'package:mobile/core/widgets/insights.dart';
import 'package:mobile/core/widgets/bottom_navigation.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopRow(),
              const SizedBox(height: 16),

              GreetingCalendar(),
              const SizedBox(height: 20),

              TodayWorkoutCard(),
              const SizedBox(height: 20),

              QuickActions(),
              const SizedBox(height: 24),

              InsightsCard(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(),
    );
  }
}
