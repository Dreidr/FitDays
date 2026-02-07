import 'package:flutter/material.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/profile/profile_tab_root.dart';
import 'package:mobile/core/widgets/bottom_navigation.dart'; // your sticky nav
import 'package:mobile/features/workout/models/day_plan.dart';

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

  String _weekdayLabel(DateTime date) {
    const labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return labels[date.weekday - 1];
  }

  DayPlan _todayPlan() {
    final today = _dateOnly(DateTime.now());
    final isWorkoutDay = _workoutDays.contains(_weekdayLabel(today));

    debugPrint("Stored workoutDays: $_workoutDays");

    // Simple 3-plan cycle (MVP). Later you can swap this to your real plan logic.
    const titles = ["Upper Body", "Lower Body", "Full Body"];
    const subtitles = ["Strength", "Strength", "Strength"];

    // Count workout days from startDate -> today (inclusive) to rotate titles only on workout days
    int workoutCount = 0;
    DateTime d = _startDate;

    while (!d.isAfter(today)) {
      final label = _weekdayLabel(d);
      if (_workoutDays.contains(label)) workoutCount++;
      d = d.add(const Duration(days: 1));
    }

    // If today is workout day, workoutCount >= 1. If rest day, workoutCount is still last workout index.
    final idx = workoutCount == 0 ? 0 : (workoutCount - 1) % titles.length;

    // For rest day, show a rest title/subtitle (nice UX for your preview too)
    if (!isWorkoutDay) {
      return DayPlan(
        date: today,
        isWorkoutDay: false,
        title: "Rest Day",
        subtitle: "Recovery",
      );
    }

    return DayPlan(
      date: today,
      isWorkoutDay: true,
      title: titles[idx],
      subtitle: subtitles[idx],
    );
  }

  @override
  void initState() {
    super.initState();

    final profile = LocalStorageService.getUserProfile();

    // name
    final storedName = profile?.name?.trim() ?? "";
    final initialName = storedName.isNotEmpty ? storedName : widget.userName;
    _userNameVN = ValueNotifier<String>(
      initialName.isNotEmpty ? initialName : "User",
    );

    // ✅ startDate + workoutDays (prefer storage)
    final storedStart =
        profile?.startDate; // <- make sure your UserProfile has this
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
        // 0
        userNameVN: _userNameVN,
        workoutStreak: widget.workoutStreak,
        startDate: _startDate,
        workoutDays: _workoutDays,
      ),
      const Placeholder(), // 1 (this is your "Streak" or whatever you want here)
      const Placeholder(), // 2 (Insights)
      ProfileTabRoot(
        // 3
        userNameVN: _userNameVN,
        onProfileUpdated: _refreshFromStorage,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        todayPlan: _todayPlan(), // ✅ add this
      ),
    );
  }
}
