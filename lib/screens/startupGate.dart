import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/screens/auth_gate.dart';
import 'package:bag_flow/screens/credentials/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Checks SharedPreferences to skip onboarding for returning users 
    final hasSeenWelcome = ref.watch(hasSeenWelcomeProvider);
    // If keep me signed in was enabled, stay signed in
    final sessionBootstrap = ref.watch(sessionBootstrapProvider);

    return sessionBootstrap.when(
      data: (_) {
        return hasSeenWelcome.when(
          // Routes user to auth gate or welcome screen 
          data: (seen) {
            if (seen) {
              return const AuthGate();
            }
            return const WelcomeScreen();
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
