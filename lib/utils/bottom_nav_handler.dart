import 'package:flutter/material.dart';
import 'package:bag_flow/screens/navBar/home_screen.dart';
import 'package:bag_flow/screens/navBar/spendingLog_screen.dart';
import 'package:bag_flow/screens/navBar/planning_screen.dart';
import 'package:bag_flow/screens/navBar/more_screen.dart';
import 'package:bag_flow/screens/navBar/addExpense_screen.dart';


Future<void> handleBottomNavTap({
  required BuildContext context,
  required int index,
  required int currentIndex,
  required Function(int) setIndex,
  Future<void> Function()? openAddExpense,
}) async {
  if (index == currentIndex && index != 2) return;

  if (index == 0) {
    setIndex(0);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } else if (index == 1) {
    setIndex(1);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SpendingLogScreen(),
      ),
    );
  } else if (index == 2) {
      setIndex(2);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AddExpenseScreen(),
        ),
      );
  } else if (index == 3) {
    setIndex(3);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PlanningScreen(),
      ),
    );
  } else if (index == 4) {
    setIndex(4);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MoreScreen(),
      ),
    );
  }
}