import 'package:flutter/material.dart';
import 'package:mobile/features/onboarding/launch_screen.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/onboarding/profile_setup_screen.dart';
import 'package:mobile/core/services/local_storage_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // 🔙 Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LaunchScreen(),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(flex: 1),

              const Align(
                alignment: Alignment(0, -0.15),
                child: Image(
                  image: AssetImage('assets/images/fitdays_logo.png'),
                  width: 320,
                  height: 320,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              // Email field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password field
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign up button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final pass = passwordController.text;
                    final confirm = confirmPasswordController.text;

                    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
                      _showToast("Please fill all fields");
                      return;
                    }

                    if (!email.contains('@')) {
                      _showToast("Please enter a valid email");
                      return;
                    }

                    if (pass != confirm) {
                      _showToast("Passwords do not match");
                      return;
                    }

                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);

                    await LocalStorageService.register(
                      email: email,
                      password: pass,
                      startDate: today, // ✅ safe default
                    );

                    if (!context.mounted) return;

                    // ✅ go to profile setup next (recommended)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSetupScreen(),
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
                    'Sign up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Spacer(),

              // Bottom login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4442D9),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
