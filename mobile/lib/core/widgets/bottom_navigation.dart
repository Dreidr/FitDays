import 'package:flutter/material.dart';
class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, color: const Color.fromARGB(255, 245, 111, 2)), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.local_fire_department, color: const Color.fromARGB(255, 245, 111, 2)), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.play_circle,color: const Color.fromARGB(255, 245, 111, 2)), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.insights,color: const Color.fromARGB(255, 245, 111, 2)), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person,color: const Color.fromARGB(255, 245, 111, 2)), label: ""),
      ],
    );
  }
}
