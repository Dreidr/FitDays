import 'package:flutter/material.dart';
import 'package:mobile/app/app_shell.dart';
import 'package:mobile/features/onboarding/launch_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = LocalStorageService.getUserProfile();
    final isLoggedIn = LocalStorageService.isLoggedIn;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: isLoggedIn
          ? AppShell(
              userName: profile?.name?.trim().isNotEmpty == true
                  ? profile!.name!.trim()
                  : "User",

              workoutStreak: 0,
              startDate: DateTime.now(),
              workoutDays: profile?.workoutDays ?? const [],
            )
          : const LaunchScreen(),
    );
  }
}
