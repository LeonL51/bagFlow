import 'package:bag_flow/providers/auth.provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/widgets/auth_googleContinue.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_password.dart';
import 'package:bag_flow/widgets/auth_validators.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:bag_flow/widgets/auth_divider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(signUpLoadingProvider);

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthHeader(
              title: "Sign Up", subtitle: "Create an account to get started"), 

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
            AuthPassword(
              controller: _passwordController,
              validator: AuthValidators.password),

            const SizedBox(height: 18),
            _termsOfService(),

            const SizedBox(height: 8),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : _signUpBtn(),

            const SizedBox(height: 20),
            AuthDivider(text: 'or'),

            const SizedBox(height: 20),
            AuthGoogleButton(onPressed: () {}),

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

        return null; 
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
      validator: (value) => AuthValidators.email(value),
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

  Widget _signUpBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signUp,
        child: const Text("Sign Up"),
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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(signUpLoadingProvider.notifier).state = true;
    final authService = ref.read(authServiceProvider);

    try {
      await authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created!")),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error")),
      );
    } finally {
      if (mounted) {
        ref.read(signUpLoadingProvider.notifier).state = false;
      }
    }
  }
}
