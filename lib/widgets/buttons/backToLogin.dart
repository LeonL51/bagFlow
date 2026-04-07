import 'package:flutter/material.dart';
import 'package:bag_flow/screens/credentials/login_screen.dart'; 

class AuthToLogin extends StatelessWidget {
  const AuthToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(.14),
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: (BorderRadius.circular(14)),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          size: 18,
        ),
      ),
    );
  }
}
