import 'package:flutter/material.dart';

class HomeTopRow extends StatelessWidget {
  const HomeTopRow({
    super.key,
    required this.streak,
    required this.week,
    this.onStreakTap,
  });

  final int streak;
  final int week;
  final VoidCallback? onStreakTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onStreakTap,
          child: _Chip(
            icon: Icons.local_fire_department,
            label: "$streak",
          ),
        ),
        _Chip(label: "Week $week"),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: const Color.fromARGB(255, 245, 111, 2)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
