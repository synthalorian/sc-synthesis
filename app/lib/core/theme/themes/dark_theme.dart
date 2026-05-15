import 'package:flutter/material.dart';

/// Dark Core — Clean, professional dark mode
class DarkTheme {
  static const Color _background = Color(0xFF121212);
  static const Color _surface = Color(0xFF1E1E1E);
  static const Color _surfaceVariant = Color(0xFF2C2C2C);
  static const Color _primary = Color(0xFF4FC3F7);
  static const Color _secondary = Color(0xFF81D4FA);
  static const Color _tertiary = Color(0xFFA5D6A7);
  static const Color _error = Color(0xFFEF5350);
  static const Color _onBackground = Color(0xFFE0E0E0);
  static const Color _onSurface = Color(0xFFCCCCCC);
  static const Color _divider = Color(0xFF3A3A3A);

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        tertiary: _tertiary,
        error: _error,
        surface: _surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: _onSurface,
      ),
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _primary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _primary, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF888888), fontSize: 12);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _divider),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(color: _onBackground),
        bodyLarge: TextStyle(color: _onSurface),
        bodyMedium: TextStyle(color: _onSurface),
        labelLarge: TextStyle(color: _primary),
      ),
    );
  }
}
