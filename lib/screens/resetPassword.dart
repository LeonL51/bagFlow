import 'package:bag_flow/providers/auth.provider.dart';
import 'package:bag_flow/widgets/auth_divider.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_password.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:bag_flow/widgets/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';

class ResetPassword extends ConsumerStatefulWidget {
  const ResetPassword({super.key});

  @override
  ConsumerState<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends ConsumerState<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetSucceeded = ref.watch(resetPasswordSuccessProvider);

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const AuthHeader(
              title: 'Forgot Password?',
              subtitle: 'Enter your email address to get the password reset link',
            ),
            const SizedBox(height: 40),
            const AuthSectionLabel(text: 'Enter new password'),
            const SizedBox(height: 5),
            AuthPassword(
              controller: _passwordController,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 15),
            const AuthSectionLabel(text: 'Re-enter new password'),
            const SizedBox(height: 5),
            AuthPassword(
              controller: _confirmPasswordController,
              validator: (value) {
                final text = value?.trim() ?? "";

                if (text.isEmpty) {
                  return "Please re-enter your password";
                }

                if (text != _passwordController.text) {
                  return "Password does not match";
                }

                return null;
              },
            ),
            const SizedBox(height: 30),
            _resetPasswordButton(resetSucceeded),
            const SizedBox(height: 20),
            const AuthDivider(text: 'or'),
            const SizedBox(height: 20),
            _backToLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _resetPasswordButton(bool resetSucceeded) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitReset,
        child: Text(
          resetSucceeded ? "Password Reset Successful" : "Change Password",
        ),
      ),
    );
  }

  Widget _backToLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.14),
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Return to Login",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _submitReset() {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fix the errors above",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(resetPasswordSuccessProvider.notifier).state = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Password reset successful",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
