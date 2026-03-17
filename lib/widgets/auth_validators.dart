import 'package:flutter/material.dart';

class AuthValidators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    if (!text.contains('@') || !text.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your password';
    if (text.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(text)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(text)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\/\[\];+=~`]').hasMatch(text)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}
