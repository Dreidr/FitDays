import 'package:flutter/material.dart';
import 'package:mobile/app/app_shell.dart';
import 'package:mobile/features/onboarding/launch_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/core/models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final completed = LocalStorageService.isOnboardingComplete;
    final UserProfile? profile = LocalStorageService.getUserProfile();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (completed && profile != null)
          ? AppShell(
              userName: profile.name.isEmpty ? "User" : profile.name,
              workoutStreak: 0,
              startDate: DateTime.now(),
              workoutDays: profile.workoutDays,
            )
          : const LaunchScreen(),
    );
  }
}
