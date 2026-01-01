import 'package:flutter/material.dart';
class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.insights), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }
}
