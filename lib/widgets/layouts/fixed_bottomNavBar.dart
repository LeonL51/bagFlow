import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,

      selectedItemColor: const Color(0xFF3B82F6),
      unselectedItemColor: Colors.white70,
      showUnselectedLabels: true,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Spending",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 32),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: "Plan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: "More",
        ),
      ],
    );
  }
}