import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        selectedItemColor: const Color(0xFF4442D9),
        unselectedItemColor: Colors.black38,

        showSelectedLabels: true,
        showUnselectedLabels: false,

        selectedFontSize: 0, // 🔒 important
        unselectedFontSize: 0, // 🔒 important
        iconSize: 24,

        items: [
          _item(Icons.home, "Home", 0),
          _item(Icons.local_fire_department, "Streak", 1),
          _centerPlayItem(2),
          _item(Icons.insights, "Insights", 3),
          _item(Icons.person, "Profile", 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _item(IconData icon, String label, int index) {
    final isActive = index == currentIndex;

    return BottomNavigationBarItem(
      label: "",
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👇 ICON OR LABEL (NOT BOTH)
          isActive
              ? Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4442D9),
                  ),
                )
              : Icon(icon),

          const SizedBox(height: 8),

          // 👇 DOT INDICATOR
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF4442D9) : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 CENTER PLAY BUTTON
  BottomNavigationBarItem _centerPlayItem(int index) {
  final isActive = index == currentIndex;

  return BottomNavigationBarItem(
    label: "",
    icon: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4442D9),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 4,
          width: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF4442D9) : Colors.transparent,
          ),
        ),
      ],
    ),
  );
}

}
