import 'package:bag_flow/login_screen.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passHidden = true;
  bool _confirmPassHidden = true;
  bool _validPass = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({String? hintText, Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF6F7F8),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.bold,
      ),
      suffixIcon: suffix,
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

                    const SizedBox(height: 40),
                    const Text(
                      "Enter new password",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),
                    _newPassword(),

                    const SizedBox(height: 15),
                    const Text(
                      'Re-enter new password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),
                    _confirmPassword(),

                    const SizedBox(height: 30),
                    _resetPasswordButton(),

                    const SizedBox(height: 15),
                    _backToLoginButton(),
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
      controller: _passwordController,
      obscureText: _passHidden,
      decoration: _fieldDecoration(
        hintText: "**********",
        suffix: IconButton(
          // Change state
          onPressed: () => setState(() => _passHidden = !_passHidden),
          icon: Icon(
            _passHidden ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) {
          return "Please enter your password";
        }
        if (text.length < 8) {
          return "Password must be at least 8 characters";
        }

        if (!RegExp(r'[A-Z]').hasMatch(text)) {
          return "Password must contain at least one uppercase letter";
        }

        if (!RegExp(r'[a-z]').hasMatch(text)) {
          return "Password must contain at least one lowercase letter";
        }

        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\/\[\];+=~`]').hasMatch(text)) {
          return "Password must contain at least one special character";
        }

        return null;
      },
    );
  }

  Widget _confirmPassword() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _confirmPassHidden,
      decoration: _fieldDecoration(
        hintText: "**********",
        suffix: IconButton(
          onPressed: () =>
              setState(() => _confirmPassHidden = !_confirmPassHidden),
          icon: Icon(
            _confirmPassHidden ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
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
    );
  }

  Widget _resetPasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
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
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF0A1F44),
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          _validPass ? "Password Reset Successful" :  "Change Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen())); 
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(.14),
          side: const BorderSide(color: Colors.white24),
          padding: EdgeInsets.symmetric(vertical: 14), 
          shape: RoundedRectangleBorder(
            borderRadius: (BorderRadius.circular(14))
          )
        ),
        child: const Text(
          "Return to Login",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w700,
          ), 
        )
      )

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
