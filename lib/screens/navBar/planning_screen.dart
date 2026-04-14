import 'package:flutter/material.dart';
import 'package:bag_flow/screens/navBar/home_screen.dart'; 

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Expense'),
      ),
      body: const Center(
        child: Text('Track Expense Screen'),
      ),
    );
  }
}