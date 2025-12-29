
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mobile/core/widgets/slide_fade.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/register_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
  body: Stack(
    fit: StackFit.expand, // force stack to fill screen
    children: [
      Image.asset(
        'assets/images/bg.jpeg',
        fit: BoxFit.cover,          // covers the whole screen
      ),

        // 2️⃣ Blur layer
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10, // horizontal blur
            sigmaY: 10, // vertical blur
          ),
          child: Container(
            color: Colors.black.withOpacity(0.1), // optional tint
          ),
        ),
      ),

      // Dark overlay to reduce exposure + improve text readability
    Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.65), // 0.2–0.55
      ),
    ),

     // App name
               Align(
                alignment: const Alignment(0, -0.15),
                child: SlideFade(
                delay: const Duration(milliseconds: 450),                 
                duration: const Duration(milliseconds: 1500),
                offset: const Offset(0, 0.35),
                curve: Curves.easeOutExpo,
                child: const Text(
                'FitDays',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: Color(0xFF4442D9),
                )
                ),
              ),
               ),




   SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        const Spacer(flex:5), // pushes everything below to bottom section

        // Tagline
        Text(
          'Ready to show up for yourself?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Button (example)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
              ),
             );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4442D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Log in",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Button (example)
        SizedBox(
          width: double.infinity,
          height: 52,
           child: ElevatedButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
              ),
             );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Sign up",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4442D9),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24), // breathing room above system UI
                const Spacer(flex: 1), // 👈 space below

      ],
    ),
  ),
),
    ],
  ),
);

  }
}
