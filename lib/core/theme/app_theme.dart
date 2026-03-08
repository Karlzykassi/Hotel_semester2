import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6E00);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color background = Color(0xFFF4F2F2);
  static const Color textPrimary = Color(0xFF252525);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color border = Color(0xFFD8D8D8);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto Mono',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        bodyLarge: const TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: const TextStyle(fontSize: 16, color: textPrimary),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        headlineSmall: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8E6E6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
    );
  }
}
