import 'package:flutter/material.dart';
import 'package:mobile/app/app_shell.dart';
import 'package:mobile/features/onboarding/launch_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/onboarding/profile_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalStorageService.init();
  await NotificationService.init();
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = LocalStorageService.getUserProfile();
    final user = FirebaseAuth.instance.currentUser;
    debugPrint("CURRENT USER: ${user?.email}");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: user == null
    ? const LaunchScreen()
    : profile == null
        ? const ProfileSetupScreen(
            allowSkip: true,
          )
        : AppShell(
            userName: profile.name?.trim().isNotEmpty == true
                ? profile.name!.trim()
                : "User",
            workoutStreak: 0,
            startDate: profile.startDate,
            workoutDays: profile.workoutDays,
          ),
    );
  }
}
