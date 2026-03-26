import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:bag_flow/screens/login_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _headerSection(),
          const SizedBox(height: 28),
          _loginButton(context, ref),
          const SizedBox(height: 12),
          _createAccountText(context, ref),
        ],
      ),
    );
  }

  Widget _headerSection() {
    return Column(
      children: [
        const Icon(
          Icons.waving_hand,
          size: 160,
          color: Color.fromARGB(255, 132, 208, 134),
        ),
        const SizedBox(height: 40),
        const Text(
          "Welcome to the app",
          textAlign: TextAlign.center,
          style: TextStyle(
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
      ],
    );
  }

  Widget _loginButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () async {
          await ref.read(preferencesServiceProvider).setHasSeenWelcome(true);

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _createAccountText(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        await ref.read(preferencesServiceProvider).setHasSeenWelcome(true);

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
      child: const Text(
        'Create an account',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}