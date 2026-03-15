import 'package:flutter/material.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:bag_flow/screens/login_screen.dart';

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

  // Input Formattting
  InputDecoration _fieldDecoration({hintText, IconData? icon, Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF6F7F8),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      suffixIcon: suffix,
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
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),
                    _fullName(),

                    const SizedBox(height: 18),
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),
                    _email(),

                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),
                    _password(),

                    const SizedBox(height: 18),
                    // Leave terms of service alone for now
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "By continuing, you agree to our "
                            ),
                            TextSpan(
                              text: "terms of service.",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 140, 254),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold 
                                ),
                            ),
                          ]
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _signUp(),

                    const SizedBox(height: 30),
                    _divider(),

                    const SizedBox(height: 30),
                    _googleButton(),

                    const SizedBox(height: 14),
                    _signIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullName() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      style: const TextStyle(color: Colors.black),
      decoration: _fieldDecoration(hintText: 'Sean Combs'),
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
      decoration: _fieldDecoration(hintText: 'jeffreyEpstein@example.com'),
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
      decoration: _fieldDecoration(
        hintText: '***************',
        suffix: IconButton(
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

    Widget _signUp() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A1F44),
        ),
        onPressed: _submitLogin,
        child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
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
