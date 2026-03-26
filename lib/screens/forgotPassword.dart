import 'package:bag_flow/widgets/auth_createAcctBtn.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _backToLoginButton(),
            const SizedBox(height: 120),
            AuthHeader(
              title: 'Forgot Password?',
              subtitle:
                  'Enter your email address to get the password reset link',
              alignment: CrossAxisAlignment.start,
            ),

            const SizedBox(height: 40),
            AuthSectionLabel(text: 'Email'),

            const SizedBox(height: 5),
            _emailInput(),

            const SizedBox(height: 15),
            _sendLinkButton(),

            const Spacer(),
            AuthCreateAccount(),
          ],
        ),
      ),
    );
  }

  Widget _backToLoginButton() {
    return SizedBox(
      width: 55,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(.14),
          side: const BorderSide(color: Colors.white24),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: (BorderRadius.circular(14)),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
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

  Widget _emailInput() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'name@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  Widget _sendLinkButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _sendResetEmail, 
        child: const Text('Send Link'),
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Reset link sent to your email")));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending email")));
    }
  }
}
