import 'package:flutter/material.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/home/home_screen.dart';
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

  late DateTime _startDate;
  late List<String> _workoutDays;

  int _currentIndex = 0;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();

    final profile = LocalStorageService.getUserProfile();

    // name
    final storedName = profile?.name?.trim() ?? "";
    final initialName = storedName.isNotEmpty ? storedName : widget.userName;
    _userNameVN = ValueNotifier<String>(initialName.isNotEmpty ? initialName : "User");

    // ✅ startDate + workoutDays (prefer storage)
    final storedStart = profile?.startDate; // <- make sure your UserProfile has this
    _startDate = _dateOnly(storedStart ?? widget.startDate);

    _workoutDays = (profile?.workoutDays.isNotEmpty == true)
        ? List<String>.from(profile!.workoutDays)
        : List<String>.from(widget.workoutDays);
  }

  void _refreshFromStorage() {
    final profile = LocalStorageService.getUserProfile();

    // refresh name
    final storedName = profile?.name?.trim() ?? "";
    _userNameVN.value = storedName.isNotEmpty ? storedName : "User";

    // ✅ refresh plan too
    final storedStart = profile?.startDate;
    setState(() {
      _startDate = _dateOnly(storedStart ?? _startDate);
      _workoutDays = (profile?.workoutDays.isNotEmpty == true)
          ? List<String>.from(profile!.workoutDays)
          : _workoutDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        userNameVN: _userNameVN,
        workoutStreak: widget.workoutStreak,
        startDate: _startDate,      // ✅ use stored
        workoutDays: _workoutDays,  // ✅ use stored
      ),
      const WorkoutTabRoot(),
      const Placeholder(),
      const Placeholder(),
      ProfileTabRoot(
        userNameVN: _userNameVN,
        onProfileUpdated: _refreshFromStorage, // ✅ refresh everything after edits
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
