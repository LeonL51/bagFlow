import 'package:flutter/material.dart';

class AuthSectionLabel extends StatelessWidget {
  final String text;

  const AuthSectionLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}