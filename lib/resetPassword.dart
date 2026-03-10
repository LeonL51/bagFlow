import 'package:bag_flow/login_screen.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
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
                    const SizedBox(height: 100),
                    _headerSection(),

                    const SizedBox(height: 60),
                    const Text(
                      "Enter new password",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      'Re-enter new password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),
                    _backToEmailButton(),
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
    return Center(
      child: Column(
        children: const [
          Text(
            'Reset Password',
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please enter your new password twice below to confirm',
            style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _newPassword() {
    return TextFormField(
      
    ); 
  }

  Widget _backToEmailButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        // Add a function here
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.14),
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Login with email",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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

    final username = _passwordController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
