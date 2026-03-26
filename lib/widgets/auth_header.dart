import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final CrossAxisAlignment alignment;
  final bool centered;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.alignment = CrossAxisAlignment.center,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final content = Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title, 
          style: textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 16),
        ),
      ],
    );

    return centered ? Center(child: content) : content;
  }
}
