import 'package:flutter/material.dart';
import 'profile_screen.dart';

class ProfileTabRoot extends StatelessWidget {
  const ProfileTabRoot({
    super.key,
    required this.userNameVN,
    required this.onProfileUpdated,
  });

  final ValueNotifier<String> userNameVN;
  final VoidCallback onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      userNameVN: userNameVN,
      onProfileUpdated: onProfileUpdated, // ✅ temporary
    );
  }
}
