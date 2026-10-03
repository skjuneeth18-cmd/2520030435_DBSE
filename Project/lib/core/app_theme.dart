import 'package:flutter/material.dart';

/// App-wide colors, text styles and theme for RaktaSetu.
class AppTheme {
  AppTheme._();

  // ---- Brand colors ----
  static const Color red = Color(0xFFD32F2F);
  static const Color redDark = Color(0xFF9A0007);
  static const Color redLight = Color(0xFFFF6F60);
  static const Color bg = Color(0xFFF7F8FA);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1B1B1F);
  static const Color textGrey = Color(0xFF6B7280);

  // ---- Status colors ----
  static const Color available = Color(0xFF2E7D32);
  static const Color limited = Color(0xFFF9A825);
  // unavailable intentionally uses red for universal familiarity.
  static const Color unavailable = red;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: red,
        primary: red,
        secondary: redDark,
      ),
      scaffoldBackgroundColor: bg,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 1.5,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: red, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        backgroundColor: Colors.white,
        selectedColor: redLight,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(color: textDark),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: redLight,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? red : textGrey,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? red : textGrey,
          ),
        ),
      ),
    );
  }
}
