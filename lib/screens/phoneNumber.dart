import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/screens/Otp.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _keepSignedIn = true;

  String _fullPhoneNumber = "";

  @override
  void dispose() {
    _phoneController.dispose();
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

                    const SizedBox(height: 40),
                    const Text(
                      "Phone Number",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),
                    _phoneNumber(),

                    const SizedBox(height: 1),
                    _keepSignedin(),
                    _getOTP(),

                    const SizedBox(height: 15),
                    _divider(),

                    const SizedBox(height: 15),
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
            'Login',
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please enter your phone number',
            style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _phoneNumber() {
    return IntlPhoneField(
      controller: _phoneController,
      dropdownIconPosition: IconPosition.trailing,
      initialCountryCode: 'US',
      disableLengthCheck: true,
      decoration: _fieldDecoration(
        hintText: _fullPhoneNumber.isEmpty ? '917-555-3333' : _fullPhoneNumber,
      ),
      validator: (phone) {
        final text = phone?.number.trim() ?? "";

        if (text.isEmpty) {
          return "Please enter your phone number";
        }

        if (text.length < 10) {
          return "Please enter only 10 numbers";
        }

        return null;
      },
      onChanged: (phone) {
        setState(() {
          _fullPhoneNumber = phone.completeNumber;
        });
      },
      onCountryChanged: (country) {
        setState(() {
          _fullPhoneNumber = "";
          _phoneController.clear();
        });
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
              _keepSignedIn = value ?? true;
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

  Widget _getOTP() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A1F44),
        ),
        // Add a function to this
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Otp()),
          );
        },
        child: const Text("Get OTP", style: TextStyle(color: Colors.white)),
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
            "or sign in with",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),

        Expanded(child: Container(height: 1, color: Colors.white24)),
      ],
    );
  }

  Widget _backToEmailButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
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

    final username = _phoneController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
