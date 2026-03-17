import 'package:bag_flow/widgets/auth_divider.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_password.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:bag_flow/widgets/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _passHidden = true;
  bool _confirmPassHidden = true;
  bool _validPass = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            AuthHeader(
              title: 'Forgot Password?',
              subtitle: 'Enter your email address to get the password reset link',
            ),

            const SizedBox(height: 40),
            AuthSectionLabel(text: 'Enter new password'), 

            const SizedBox(height: 5),
            AuthPassword(
              controller: _passwordController,
              validator: (value) => AuthValidators.password(value)),

            const SizedBox(height: 15),
            AuthSectionLabel(text: 'Re-enter new password'), 

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
              }
            ),

            const SizedBox(height: 30),
            _resetPasswordButton(),

            const SizedBox(height: 20),
            AuthDivider(text: 'or'),

            const SizedBox(height: 20),
            _backToLoginButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _resetPasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Default: passes all validators
          final isValid = _formKey.currentState!.validate();

          // If validators are not ALL passed, return an error message
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

          // Change the state of validity to true when all validation is
          setState(() {
            _validPass = true;
          });

          // Change the content of the snackbar to reflect successful reset
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Password reset successful",
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: Text(
          _validPass 
            ? "Password Reset Successful" 
            : "Change Password"
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
          backgroundColor: Colors.white.withOpacity(.14),
          side: const BorderSide(color: Colors.white24),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: (BorderRadius.circular(14)),
          ),
        ),
        child: const Text(
          "Return to Login",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // Review what this does
  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _passwordController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
