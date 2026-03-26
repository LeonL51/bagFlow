import 'package:bag_flow/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/auth_backToLoginBtn.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';

class Otp extends StatefulWidget {
  final String verificationId;

  const Otp({super.key, required this.verificationId});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthToLogin(),

          const SizedBox(height: 100),
          const AuthHeader(
            title: 'OTP Verification',
            subtitle:
                'Enter the verification code we just sent to your phone number',
            centered: true,
          ),
          const SizedBox(height: 40),
          _otpFields(),
          const SizedBox(height: 30),
          _verifyButton(),
        ],
      ),
    );
  }

  Widget _otpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 60,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textInputAction: index == _otpControllers.length - 1
                ? TextInputAction.done
                : TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(fontSize: 20, color: Colors.black),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: const Color(0xFFF6F7F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < _focusNodes.length - 1) {
                  _focusNodes[index + 1].requestFocus();
                }
              } else {
                if (index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              }
            },
            onTap: () {
              _otpControllers[index].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _otpControllers[index].text.length,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _verifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitOtp,
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text("Verify OTP"),
      ),
    );
  }

  Future<void> _submitOtp() async {
    final smsCode = _otpControllers.map((c) => c.text).join();

    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOTP(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Phone login successful")));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Invalid OTP")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
