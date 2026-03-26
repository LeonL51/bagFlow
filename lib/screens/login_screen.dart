import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/auth_createAcctBtn.dart';
import 'package:bag_flow/widgets/auth_googleContinue.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_validators.dart';
import 'package:bag_flow/screens/forgotPassword.dart';
import 'package:bag_flow/screens/phoneNumber.dart';
import 'package:bag_flow/widgets/auth_divider.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:bag_flow/widgets/auth_password.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _useEmail = true;
  bool _isLoading = false;
  bool _forgotPassword = false;
  bool _keepSignedIn = true;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(
              title: "Login",
              subtitle: "Welcome back to the app",
            ),

            const SizedBox(height: 26),
            _loginMethodTabs(),

            const SizedBox(height: 18),
            AuthSectionLabel(text: _useEmail ? 'Email' : 'Phone Number'),

            const SizedBox(height: 4),
            _email(),

            const SizedBox(height: 20),
            _passwordOptions(),

            const SizedBox(height: 4),
            AuthPassword(
              controller: _passwordController,
              validator: (value) {
                final text = value?.trim() ?? "";

                if (text.isEmpty) return 'Please enter your password';

                return null;
              },
            ),
            _keepSignedin(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loginButton(),

            const SizedBox(height: 30),
            const AuthDivider(text: 'or sign in with'),

            const SizedBox(height: 30),
            AuthGoogleButton(onPressed: () {}),

            const SizedBox(height: 14),
            AuthCreateAccount(),
          ],
        ),
      ),
    );
  }

  Widget _loginMethodTabs() {
    return Row(
      children: [
        _tabButton(
          title: "Email",
          selected: true,
          onTap: () => setState(() => _useEmail = true),
        ),
        const SizedBox(width: 15),
        _tabButton(
          title: "Phone Number",
          selected: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PhoneNumber()),
            );
          },
        ),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF3B82F6) : Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          decoration: selected ? TextDecoration.underline : TextDecoration.none,
          decorationColor: const Color(0xFF3B82F6),
          decorationThickness: 2,
        ),
      ),
    );
  }

  Widget _passwordOptions() {
    return Row(
      children: [
        AuthSectionLabel(text: 'Password'),
        const Spacer(),
        _tabButton(
          title: "Forgot Password?",
          selected: !_forgotPassword,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForgotPassword()),
            );
          },
        ),
      ],
    );
  }

  Widget _email() {
    return TextFormField(
      controller: _useEmail ? _emailController : _phoneController,
      keyboardType: _useEmail
          ? TextInputType.emailAddress
          : TextInputType.phone,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: _useEmail ? 'name@example.com' : '9175553333',
        prefixIcon: Icon(
          _useEmail ? Icons.email_outlined : Icons.phone_outlined,
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (_useEmail) {
          return AuthValidators.email(value);
        } else {
          final text = value?.trim() ?? "";
          if (text.isEmpty) return 'Please enter your phone number';
          final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
          if (digitsOnly.length < 10) {
            return "Enter a valid phone number";
          }
        }
        return null;
      },
    );
  }

  Widget _keepSignedin() {
    return Row(
      children: [
        Checkbox(
          value: _keepSignedIn,
          onChanged: (value) {
            setState(() {
              _keepSignedIn = value!;
            });
          },
          activeColor: const Color(0xFF2563EB),
          checkColor: Colors.white,
        ),
        const SizedBox(width: 2),
        const Text(
          "Keep me signed in",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Replace this function
        onPressed: _login,
        child: const Text('Login'),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Successful")));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
