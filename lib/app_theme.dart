import 'package:flutter/material.dart';

class AppTheme {

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color deepBlue = Color(0xFF0A1F44);
  static const Color inputFill = Color(0xFFF6F7F8);
  static const Color inputHint = Color(0xFF9CA3AF);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color linkBlue = Color(0xFF93C5FD);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: Colors.black,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE5E7EB),
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE5E7EB),
      ),

      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,

      hintStyle: const TextStyle(
        color: inputHint,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: inputBorder),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: inputBorder),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: linkBlue,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}