class AuthValidators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Please enter your email';

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    if (!emailRegex.hasMatch(text)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please enter your password';
    if (text.length < 8) return 'Password must be at least 8 characters';
    if (text.length > 32) {
      return 'Password is too long';
    }
    if (text.contains(' ')) {
      return 'Password cannot contain spaces';
    }
    if (!RegExp(r'[A-Z]').hasMatch(text)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(text)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(text)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[_^$*.\[\]{}()?\-"!@#%&/\\,><:;|~`+=]').hasMatch(text)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}
