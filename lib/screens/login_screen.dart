import 'package:bag_flow/screens/forgotPassword.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/screens/signUp_screen.dart';
import 'package:bag_flow/screens/phoneNumber.dart'; 

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

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _useEmail = true;
  bool _isLoading = false;
  bool _passHidden = true;
  bool _forgotPassword = true; 
  bool _keepSignedIn = true;

  // Input Formattting 
  InputDecoration _fieldDecoration({
    required hintText, 
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey), 
      filled: true,
      fillColor: const Color(0xFFF6F7F8),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
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
                    _headerSection(),

                    const SizedBox(height: 26),
                    _loginMethodTabs(),

                    const SizedBox(height: 18),
                    const Text('Email', 
                    style: TextStyle(color: Colors.white)),

                    const SizedBox(height: 4),
                    _email(),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Password', 
                          style: TextStyle(color: Colors.white)
                        ),
                        const Spacer(),
                        _tabButton(
                          title: "Forgot Password?",
                          selected: _forgotPassword, 
                          onTap: () => {
                            Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => const ForgotPassword())),
                          }
                        ), 
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    _password(),

                    const SizedBox(height: 18),
                    _keepSignedin(),

                    const SizedBox(height: 8),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _loginButton(),

                    const SizedBox(height: 30),
                    _divider(),

                    const SizedBox(height: 30),
                    _googleButton(),

                    const SizedBox(height: 14),
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
    return Center(
      child: Column(
        children: const [
          Text('Login', style: TextStyle(
            fontSize: 36, 
            color: Colors.white,
            fontWeight: FontWeight.bold, 
          )),
          SizedBox(height: 10),
          Text(
            'Welcome back to the app',
            style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 16),
          ),
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

            Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => const PhoneNumber()), 
            );
          }
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
      decoration: _fieldDecoration(
        hintText: "jeffreyEpstein@gmail.com", 
        icon: _useEmail ? Icons.email_outlined : Icons.phone_outlined,
      ),
      validator: (value) {
        // What does this mean?
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
          // Review this
          final digits = text.replaceAll(RegExp(r'\D'), '');
          if (digits.length < 10) {
            return "Enter a valid phone number";
          }
        }
        return null;
      },
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A1F44),
        ),
        onPressed: _submitLogin,
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _password() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _passHidden,
      style: const TextStyle(color: Colors.black),
      decoration: _fieldDecoration(
        hintText: "**************",
        icon: Icons.lock_outline,
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
        return null; 
      },
    );
  }

  Widget _keepSignedin() {
    return Row(
      children: [
        // Review this
        Checkbox(
          value: _keepSignedIn,
          onChanged: (value) {
            setState(() {
              // Value becomes false and unchecked 
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

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white24)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "or sign in with",
            style: TextStyle(color: Colors.white70, fontSize: 14),
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

  // Review what this does 
  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    final username = _useEmail
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$username is logged in")),
    );
  }
}
