import 'package:flutter/material.dart';
import 'package:bag_flow/screens/forgotPassword.dart';
import 'package:bag_flow/screens/phoneNumber.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:bag_flow/widgets/auth_divider.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:bag_flow/widgets/auth_section_label.dart'; 

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
  bool _passHidden = true;
  bool _forgotPassword = true;
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
            _headerSection(),
            const SizedBox(height: 26),
            _loginMethodTabs(),
            const SizedBox(height: 18),
            AuthSectionLabel(text: _useEmail ? 'Email' : 'Phone Number'),
            const SizedBox(height: 4),
            _email(),
            const SizedBox(height: 20),
            Row(
              children: [
                AuthSectionLabel(text: 'Password'),
                const Spacer(),
                _tabButton(
                  title: "Forgot Password?",
                  selected: _forgotPassword,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPassword(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            _password(),
            _keepSignedin(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loginButton(),
            const SizedBox(height: 30),
            const AuthDivider(text: 'or sign in with'), 
            const SizedBox(height: 30),
            _googleButton(),
            const SizedBox(height: 14),
            _createAccount(),
          ],
        ),
      ),
    );
  }

  Widget _headerSection() {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        children: [
          Text('Login', style: textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text('Welcome back to the app', style: textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _loginMethodTabs() {
    return Row(
      children: [
        _tabButton(
          title: "Email",
          selected: _useEmail,
          onTap: () => setState(() => _useEmail = true),
        ),
        const SizedBox(width: 18),
        _tabButton(
          title: "Phone Number",
          selected: !_useEmail,
          onTap: () {
            setState(() => _useEmail = false);
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

        if (text.isEmpty) {
          return _useEmail
              ? "Please enter your email"
              : "Please enter your phone number";
        }

        if (_useEmail) {
          if (!text.contains('@') || !text.contains('.')) {
            return "Please enter a valid email";
          }
        } else {
          final digits = text.replaceAll(RegExp(r'\D'), '');
          if (digits.length < 10) {
            return "Enter a valid phone number";
          }
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
        hintText: "**************",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _passHidden = !_passHidden),
          icon: Icon(_passHidden ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) {
          return "Please enter your password";
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
        onPressed: _submitLogin,
        child: const Text('Login'),
      ),
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
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

  Widget _createAccount() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
        },
        child: const Text(
          "Create an account",
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
        : _phoneController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
