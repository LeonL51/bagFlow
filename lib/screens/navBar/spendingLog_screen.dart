import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';

class SpendingLogScreen extends StatefulWidget {
  const SpendingLogScreen({super.key});

  @override
  State<SpendingLogScreen> createState() => _SpendingLogScreenState();
}

class _SpendingLogScreenState extends State<SpendingLogScreen> {
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

      
    );
  }
}