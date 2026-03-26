import 'package:bag_flow/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/auth_createAcctBtn.dart';
import 'package:bag_flow/widgets/auth_divider.dart';
import 'package:bag_flow/widgets/auth_googleContinue.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:bag_flow/widgets/auth_section_label.dart';
import 'package:bag_flow/screens/Otp.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';
import 'package:bag_flow/widgets/auth_backToLoginBtn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String digits) {
    if (digits.isEmpty) return "";

    if (digits.length <= 3) {
      return "($digits";
    } else if (digits.length <= 6) {
      return "(${digits.substring(0, 3)}) ${digits.substring(3)}";
    } else {
      return "(${digits.substring(0, 3)}) "
          "${digits.substring(3, 6)}-"
          "${digits.substring(6, digits.length > 10 ? 10 : digits.length)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthToLogin(),
            const SizedBox(height: 100),
            const AuthHeader(
              title: 'Login',
              subtitle: 'Please enter your phone number',
            ),
            const SizedBox(height: 35),
            const AuthSectionLabel(text: 'Phone Number'),
            const SizedBox(height: 5),
            _phoneNumber(),
            const SizedBox(height: 15),
            _getOTP(),
            const SizedBox(height: 15),
            const AuthDivider(text: 'or sign in with'),
            const SizedBox(height: 15),
            AuthGoogleButton(onPressed: () {}),
            const Spacer(),
            AuthCreateAccount(),
          ],
        ),
      ),
    );
  }

  Widget _phoneNumber() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        hintText: '(917) 555-3333',
        prefixIcon: Icon(Icons.phone),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) {
          return "Please enter your phone number";
        }

        final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

        if (digitsOnly.length != 10) {
          return "Enter a valid 10-digit phone number";
        }

        return null;
      },
      onChanged: (value) {
        final digits = value.replaceAll(RegExp(r'\D'), '');
        final formatted = _formatPhoneNumber(digits);

        if (formatted != value) {
          _phoneController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
    );
  }

  Widget _getOTP() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyPhone,
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Get OTP'),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;

    final digitsOnly = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phoneNumber = '+1$digitsOnly';

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _authService.signInWithCredential(credential);

          if (!mounted) return;

          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phone number verified automatically")),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Phone verification failed")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() => _isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Otp(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;

          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}