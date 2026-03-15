import 'dart:ui';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:bag_flow/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand,
            size: 160,
            color: const Color.fromARGB(255, 132, 208, 134),
          ),
          const SizedBox(height: 40),

          Text(
            "Welcome to the app",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            "Built to help you manage money without the stress.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.85),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),

          _buildButton(
            text: "Login",
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
            },
            child: const Text(
              "Create an account",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF0A1F44),
        padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
