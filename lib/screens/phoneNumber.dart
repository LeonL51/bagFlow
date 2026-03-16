import 'package:bag_flow/widgets/auth_divider.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/screens/Otp.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String _fullPhoneNumber = "";

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            AuthHeader(
              title: 'Login',
              subtitle: 'Please enter your phone number',
            ),

            const SizedBox(height: 40),
            AuthSectionLabel(text: 'Phone Number'),

            const SizedBox(height: 5),
            _phoneNumber(),

            const SizedBox(height: 15),
            _getOTP(),

            const SizedBox(height: 15),
            AuthDivider(text: 'or sign in with'),

            const SizedBox(height: 15),
            _backToEmailButton(),
          ],
        ),
      ),
    );
  }

  Widget _phoneNumber() {
    return IntlPhoneField(
      controller: _phoneController,
      dropdownIconPosition: IconPosition.trailing,
      initialCountryCode: 'US',
      disableLengthCheck: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
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

  Widget _getOTP() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Add a function to this
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Otp()),
          );
        },
        child: const Text('Get OTP'),
      ),
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

    final username = _phoneController.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$username is logged in")));
  }
}
