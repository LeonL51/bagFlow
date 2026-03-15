import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bag_flow/signUp_screen.dart';
import 'package:bag_flow/login_screen.dart';

/// Entry screen shown before the user authenticates.
///
/// This screen introduces the app and provides navigation
/// to the login and sign-up flows.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

/// State implementation for [WelcomeScreen].
class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background hero image used to establish the screen's visual tone.
          const Image(
            image: AssetImage('assets/images/welcome_bkgd.jpg'),
            fit: BoxFit.cover,
          ),

          // Dark gradient overlay improves foreground contrast and keeps
          // text readable across different areas of the background image.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
          ),

          // Subtle blur softens background details so the primary content
          // remains the visual focus without fully hiding the image.
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(color: Colors.transparent),
          ),

          // Foreground content is wrapped in SafeArea to avoid system UI
          // overlap on devices with notches, status bars, or rounded corners.
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Friendly hero icon that reinforces the welcoming tone
                    // of the entry experience.
                    Icon(
                      Icons.waving_hand,
                      size: 160,
                      color: const Color.fromARGB(255, 132, 208, 134),
                    ),
                    const SizedBox(height: 40),

                    // Primary heading introducing the app to the user.
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

                    // Supporting copy communicates the app's value proposition
                    // in a short, low-friction message.
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

                    // Primary call-to-action directing returning users
                    // into the login flow.
                    _buildButton(
                      text: "Login",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Secondary action for new users who need to create
                    // an account before accessing the app.
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the primary styled button used on this screen.
  ///
  /// Extracting this into a helper keeps button styling consistent and
  /// makes the build method easier to scan.
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF0A1F44),
        padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
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