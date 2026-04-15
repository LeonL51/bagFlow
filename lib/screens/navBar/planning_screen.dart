import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Planning',
        onMenuTap: () {},
      ),
      body: const Center(
        child: Text('Planning Screen'),
      ),
    );
  }
}