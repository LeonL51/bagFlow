import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/widgets/buttons/backToLogin.dart';
import 'package:bag_flow/widgets/buttons/createAccount.dart';
import 'package:bag_flow/widgets/buttons/googleContinue.dart';
import 'package:bag_flow/widgets/layouts/divider.dart';
import 'package:bag_flow/widgets/layouts/header.dart';
import 'package:bag_flow/widgets/layouts/scaffold.dart';
import 'package:bag_flow/widgets/layouts/sectionLabel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/screens/Otp.dart';

import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumber extends ConsumerStatefulWidget {
  const PhoneNumber({super.key});

  @override
  ConsumerState<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends ConsumerState<PhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

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
    final isLoading = ref.watch(phoneVerificationLoadingProvider);

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
            _getOTP(isLoading),
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

  Widget _getOTP(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _verifyPhone,
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text('Get OTP'),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;

    final digitsOnly = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phoneNumber = '+1$digitsOnly';

    ref.read(phoneVerificationLoadingProvider.notifier).state = true;
    final authService = ref.read(authServiceProvider);

    try {
      await authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await authService.signInWithCredential(credential);

          if (!mounted) return;

          ref.read(phoneVerificationLoadingProvider.notifier).state = false;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phone number verified automatically")),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          ref.read(phoneVerificationLoadingProvider.notifier).state = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Phone verification failed")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          ref.read(phoneVerificationLoadingProvider.notifier).state = false;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Otp(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;

          ref.read(phoneVerificationLoadingProvider.notifier).state = false;
        },
      );
    } catch (e) {
      if (!mounted) return;

      ref.read(phoneVerificationLoadingProvider.notifier).state = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
