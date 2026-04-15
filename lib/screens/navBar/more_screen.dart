import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'More',
        onMenuTap: () {},
      ),
      body: const Center(
        child: Text('More Screen'),
      ),
    );
  }
}