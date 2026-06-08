import 'package:flutter/material.dart';

class AppDecorations {
  AppDecorations._(); // private constructor

  /// Primary surface card (Home, Insights, Workout)
  static BoxDecoration card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4442D9).withValues(alpha: 0.22),
                const Color(0xFF4442D9).withValues(alpha: 0.10),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4442D9).withValues(alpha: 0.10),
                const Color(0xFF4442D9).withValues(alpha: 0.03),
              ],
            ),
      borderRadius: BorderRadius.circular(20),
    );
  }
}
