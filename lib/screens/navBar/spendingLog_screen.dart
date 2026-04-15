import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';

class SpendingLogScreen extends StatefulWidget {
  const SpendingLogScreen({super.key});

  @override
  State<SpendingLogScreen> createState() => _SpendingLogScreenState();
}

class _SpendingLogScreenState extends State<SpendingLogScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Spending Log',
        onMenuTap: () {},
      ),
      body: const Center(
        child: Text('Spending Log Screen'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          await handleBottomNavTap(
            context: context,
            index: index,
            currentIndex: _currentIndex,
            setIndex: (i) => setState(() => _currentIndex = i),
          );
        },
      ),
    );
  }
}