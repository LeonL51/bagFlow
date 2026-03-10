import 'package:bag_flow/login_screen.dart';
import 'package:bag_flow/resetPassword.dart';
import 'package:bag_flow/signUp_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _isLoading = false;
  bool _keepSignedIn = true;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF6F7F8),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage('assets/images/welcome_bkgd.jpg'),
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.55),
                  Colors.black.withOpacity(.35),
                  Colors.black.withOpacity(.55),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    _headerSection(),

                    const SizedBox(height: 60),
                    const Text(
                      "Email Address",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    _emailInput(),

                    const SizedBox(height: 15),
                    _passwordReset(), 

                    const Spacer(),
                    _createAccount(),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      decoration: _fieldDecoration(hintText: 'jeffreyEpstein@gmail.com'),
    );
  }

  Widget _passwordReset() {
    return SizedBox(
      width: double.infinity,
      height: 50, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A1F44),
        ),
        // Should send email link
        // When confirmed, directs to reset password page 
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: 
              (context) => ResetPassword()), 
          ); 
        },
        child: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white), 
        ),
      )
    );
  }

  Widget _createAccount() {
    return Center(
      // After wrapped, add a child
      child: TextButton(
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => SignUpScreen())); 
        },
        child: Text(
          "Create an account",
          style: TextStyle(color: Color(0xFF93C5FD), 
          fontWeight: FontWeight.w700
          ),
        ),
      ),
    );
  }

  // Review what this does
  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    final username = _emailController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
