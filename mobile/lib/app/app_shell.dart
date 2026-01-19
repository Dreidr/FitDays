import 'package:flutter/material.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/profile/profile_screen.dart';
import 'package:mobile/features/profile/profile_tab_root.dart';
import 'package:mobile/features/workout/workout_tab_root.dart'; // adjust if needed
import 'package:mobile/core/widgets/bottom_navigation.dart'; // your sticky nav

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.userName,
    required this.workoutStreak,
    required this.startDate,
    required this.workoutDays,
  });

  final String userName; // keep String API (main.dart is already using this)
  final int workoutStreak;
  final DateTime startDate;
  final List<String> workoutDays;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ValueNotifier<String> _userNameVN;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Prefer storage value if exists, else fall back to the passed-in name
    final stored = LocalStorageService.getUserProfile()?.name?.trim() ?? "";
    final initial = stored.isNotEmpty ? stored : widget.userName;

    _userNameVN = ValueNotifier<String>(initial.isNotEmpty ? initial : "User");
  }

  @override
  void dispose() {
    _userNameVN.dispose();
    super.dispose();
  }

  void _refreshNameFromStorage() {
    final stored = LocalStorageService.getUserProfile()?.name?.trim() ?? "";
    _userNameVN.value = stored.isNotEmpty ? stored : "User";
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        userNameVN: _userNameVN,
        workoutStreak: widget.workoutStreak,
        startDate: widget.startDate,
        workoutDays: widget.workoutDays,
      ),

      // If you have a Workout tab root/screen:
      const WorkoutTabRoot(),
      const Placeholder(), // Play screen (temporary)
      const Placeholder(), // Stats/Progress (temporary)
      // Profile screen should be able to edit name and update VN:
      ProfileTabRoot(
        userNameVN: _userNameVN,
        onProfileUpdated: _refreshNameFromStorage, // call after saving name
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
