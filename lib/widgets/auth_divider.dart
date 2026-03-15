import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.white24)),
      ],
    );
  }
}