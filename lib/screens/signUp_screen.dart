import 'package:flutter/material.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:bag_flow/widgets/auth_divider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _passHidden = true;
  bool _useEmail = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                "Create an Account",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
            ),

            const SizedBox(height: 40),
            AuthSectionLabel(text: 'Full Name'),

            const SizedBox(height: 4),
            _fullName(),

            const SizedBox(height: 18),
            AuthSectionLabel(text: 'Email Address'),

            const SizedBox(height: 4),
            _email(),

            const SizedBox(height: 20),
            AuthSectionLabel(text: 'Password'),

            const SizedBox(height: 4),
            _password(),

            const SizedBox(height: 18),
            _termsOfService(),

            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _signUp(),

            const SizedBox(height: 20),
            AuthDivider(text: 'or'),

            const SizedBox(height: 20),
            _googleButton(),

            const SizedBox(height: 14),
            _signIn(),
          ],
        ),
      ),
    );
  }

  Widget _fullName() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'John Doe',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) {
          return "Please enter your full name";
        }

        final parts = text.split(" ");

        if (parts.length < 2) {
          return "Please enter both first and last name";
        }

        if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\/\[\];+=~`]').hasMatch(text)) {
          return "Please enter a valid full name";
        }
      },
    );
  }

  Widget _email() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'hello@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) {
          return "Please enter your email";
        }

        if (!text.contains('@') || !text.contains('.')) {
          return "Please enter a valid email";
        }

        return null;
      },
    );
  }

  Widget _password() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _passHidden,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: '***************',
        prefixIcon: Icon(Icons.lock_open_outlined),
        suffixIcon: IconButton(
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

  Widget _termsOfService() {
    return Center(
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(text: "By continuing, you agree to our "),
            TextSpan(
              text: "terms of service.",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 140, 254),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signUp() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitLogin,
        child: const Text("Sign Up"),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white24)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "or ",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.white24)),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        // Add a function here
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.14),
          // See what the side does
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
              "Continue with Google",
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

  Widget _signIn() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
        child: const Text(
          "Already have an account? Sign in here",
          style: TextStyle(
            color: Color(0xFF93C5FD),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    final username = _useEmail
        ? _emailController.text.trim()
        : _nameController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
