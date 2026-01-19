import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.userName,
    required this.streak,
    required this.workoutMinutes,
    required this.completedWorkouts,
    required this.onSettingsTap,
  });

  final String userName;
  final int streak;
  final int workoutMinutes;
  final int completedWorkouts;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final initials = userName.isNotEmpty
        ? userName.trim().split(" ").map((e) => e[0]).take(2).join()
        : "U";

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4442D9).withOpacity(0.9),
            const Color(0xFF2F2ECF).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4442D9).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ornaments (subtle circles)
          const Positioned(
            top: -30,
            right: -20,
            child: _Ornament(size: 120, opacity: 0.08),
          ),
         

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              children: [
                // Settings button
                Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: onSettingsTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.settings,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Avatar
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4442D9),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Name
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                // Stats pill
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItemLight(
                        value: "$streak",
                        label: "Activity\nStreak",
                      ),
                      _LightDivider(),
                      _StatItemLight(
                        value: "$workoutMinutes",
                        label: "Workout\nMinutes",
                      ),
                      _LightDivider(),
                      _StatItemLight(
                        value: "$completedWorkouts",
                        label: "Completed\nWorkouts",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _StatItemLight extends StatelessWidget {
  const _StatItemLight({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _LightDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withOpacity(0.35),
    );
  }
}

