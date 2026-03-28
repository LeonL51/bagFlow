import 'package:flutter/material.dart';
import 'dart:ui';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage('assets/images/welcome_bkgd.jpg'),
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.55),
                  Colors.black.withOpacity(.35),
                  Colors.black.withOpacity(.55),
                ],
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}