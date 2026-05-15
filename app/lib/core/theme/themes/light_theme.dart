import 'package:flutter/material.dart';

/// Light Core — Clean, professional light mode
class LightTheme {
  static const Color _background = Color(0xFFF5F5F5);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceVariant = Color(0xFFEEEEEE);
  static const Color _primary = Color(0xFF0288D1);
  static const Color _secondary = Color(0xFF039BE5);
  static const Color _tertiary = Color(0xFF43A047);
  static const Color _error = Color(0xFFD32F2F);
  static const Color _onBackground = Color(0xFF212121);
  static const Color _onSurface = Color(0xFF424242);
  static const Color _divider = Color(0xFFBDBDBD);

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primary,
        secondary: _secondary,
        tertiary: _tertiary,
        error: _error,
        surface: _surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _onSurface,
      ),
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _primary, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF757575), fontSize: 12);
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
          foregroundColor: Colors.white,
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
