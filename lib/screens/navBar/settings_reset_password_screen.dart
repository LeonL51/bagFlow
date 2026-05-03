import 'package:bag_flow/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsResetPasswordScreen extends ConsumerStatefulWidget {
  const SettingsResetPasswordScreen({super.key});

  @override
  ConsumerState<SettingsResetPasswordScreen> createState() =>
      _SettingsResetPasswordScreenState();
}

class _SettingsResetPasswordScreenState
    extends ConsumerState<SettingsResetPasswordScreen> {
  bool _isSending = false;

  Future<void> _sendResetEmail() async {
    final user = ref.read(authServiceProvider).currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      _showMessage('No email found for this account');
      return;
    }

    setState(() => _isSending = true);

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showMessage('Password reset link sent to $email');
    } catch (e) {
      _showMessage('Could not send reset email: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF3B82F6),
                size: 58,
              ),
              const SizedBox(height: 18),
              const Text(
                'Reset your password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We will send a password reset link to:\n${user?.email ?? 'No email found'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendResetEmail,
                  child: _isSending
                      ? const CircularProgressIndicator()
                      : const Text('Send Reset Link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}