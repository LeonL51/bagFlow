import 'package:flutter/material.dart';

class AuthPassword extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AuthPassword({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<AuthPassword> createState() => _AuthPasswordState();
}

class _AuthPasswordState extends State<AuthPassword> {
  bool _passHidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _passHidden,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "***************",
        prefixIcon: Icon(Icons.lock_open_outlined),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _passHidden = !_passHidden),
          icon: Icon(
            _passHidden ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
      // What does it mean to say widget.validator 
      validator: widget.validator,
    );
  }
}