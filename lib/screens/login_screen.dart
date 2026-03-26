import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:bag_flow/providers/auth.provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useEmail = ref.watch(loginUseEmailProvider);
    final isLoading = ref.watch(loginLoadingProvider);
    final keepSignedIn = ref.watch(loginKeepSignedInProvider);

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
            _loginMethodTabs(useEmail),

            const SizedBox(height: 18),
            AuthSectionLabel(text: useEmail ? 'Email' : 'Phone Number'),

            const SizedBox(height: 4),
            _email(useEmail),

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
            _keepSignedin(keepSignedIn),
            isLoading
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

  Widget _loginMethodTabs(bool useEmail) {
    return Row(
      children: [
        _tabButton(
          title: "Email",
          selected: useEmail,
          onTap: () => ref.read(loginUseEmailProvider.notifier).state = true,
        ),
        const SizedBox(width: 15),
        _tabButton(
          title: "Phone Number",
          selected: !useEmail,
          onTap: () {
            ref.read(loginUseEmailProvider.notifier).state = false;
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
          selected: false,
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

  Widget _email(bool useEmail) {
    return TextFormField(
      controller: useEmail ? _emailController : _phoneController,
      keyboardType: useEmail ? TextInputType.emailAddress : TextInputType.phone,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: useEmail ? 'name@example.com' : '9175553333',
        prefixIcon: Icon(
          useEmail ? Icons.email_outlined : Icons.phone_outlined,
        ),
      ),
      validator: (value) {
        if (useEmail) {
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

  Widget _keepSignedin(bool keepSignedIn) {
    return Row(
      children: [
        Checkbox(
          value: keepSignedIn,
          onChanged: (value) {
            ref.read(loginKeepSignedInProvider.notifier).state = value ?? true;
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

    ref.read(loginLoadingProvider.notifier).state = true;
    final authService = ref.read(authServiceProvider);

    try {
      await authService.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
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
        ref.read(loginLoadingProvider.notifier).state = false;
      }
    }
  }
}
