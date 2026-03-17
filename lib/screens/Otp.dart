import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bag_flow/widgets/auth_scaffold.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 140),
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
      ),
    );
  }

  Widget _otpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return SizedBox(
          width: 60,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textInputAction:
                index == _otpControllers.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '';
              }
              // Why return null 
              return null;
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < _focusNodes.length) {
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
        onPressed: _submitOtp,
        child: const Text("Verify OTP"),
      ),
    );
  }

  void _submitOtp() {
    if (!_formKey.currentState!.validate()) return;

    final otpCode = _otpControllers.map((controller) => controller.text).join();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("OTP entered: $otpCode")));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}