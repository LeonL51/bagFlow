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

  if (index == currentIndex) return;

  Widget screen;
  switch (index) {
    case 0:
      screen = const HomeScreen();
      break;
    case 1:
      screen = const SpendingLogScreen();
      break;
    case 2:
      screen = const AddExpenseScreen();
      break;
    case 3:
      screen = const PlanningScreen();
      break;
    case 4:
      screen = const MoreScreen();
      break;
    default:
      return;
  }

  setIndex(index);

  await Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => screen),
  );
}