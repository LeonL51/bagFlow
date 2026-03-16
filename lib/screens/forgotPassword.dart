import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/screens/resetPassword.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
            _headerSection(),

            const SizedBox(height: 40),
            AuthSectionLabel(text: 'Email'), 

            const SizedBox(height: 5),
            _emailInput(),

            const SizedBox(height: 15),
            _sendLinkButton(),

            const Spacer(),
            _createAccount(),
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

  Widget _headerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Enter your email address to get the password reset link',
          style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 16),
        ),
      ],
    );
  }

  Widget _emailInput() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'hello@example.com',
        prefixIcon: Icon(
          Icons.email_outlined
        ),
      ),
    );
  }

  Widget _sendLinkButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPassword()),
          );
        },
        child: const Text('Send Link'),
      ),
    );
  }

  Widget _createAccount() {
    return Center(
      // After wrapped, add a child
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          );
        },
        child: Text(
          "Create an account",
          style: TextStyle(
            color: Color(0xFF93C5FD),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Review what this does
  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _emailController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
