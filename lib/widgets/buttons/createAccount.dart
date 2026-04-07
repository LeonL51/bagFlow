import 'package:flutter/material.dart'; 
import 'package:bag_flow/screens/credentials/signUp_screen.dart'; 

class AuthCreateAccount extends StatelessWidget {
  const AuthCreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ),
          );
        },
        child: const Text(
          'Create an account',
          style: TextStyle(
            color: Color(0xFF93C5FD),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}