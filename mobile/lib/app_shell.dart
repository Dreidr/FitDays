import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/bottom_navigation.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/workout/workout_tab_root.dart';



class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.userName,
    required this.workoutStreak,
    required this.startDate,
    required this.workoutDays,
  });

  final String userName;
  final int workoutStreak;
  final DateTime startDate;
  final List<String> workoutDays;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _keys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  void _onTap(int i) {
    if (i == _index) {
      _keys[i].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          Navigator(
            key: _keys[0],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => HomeScreen(
                userName: widget.userName,
                workoutStreak: widget.workoutStreak,
                startDate: widget.startDate,
                workoutDays: widget.workoutDays,
              ),
            ),
          ),
          Navigator(
            key: _keys[1],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const Scaffold(body: Center(child: Text("Streak"))),
            ),
          ),
          Navigator(
            key: _keys[2],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const WorkoutTabRoot(),
            ),
          ),
          Navigator(
            key: _keys[3],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const Scaffold(body: Center(child: Text("Insights"))),
            ),
          ),
          Navigator(
            key: _keys[4],
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const Scaffold(body: Center(child: Text("Profile"))),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: _onTap,
      ),
    );
  }
}
