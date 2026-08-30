import 'package:flutter/material.dart';

/// Blackshield — steel and blood. Forged for the mercenary.
class BlackshieldTheme {
  static const Color _background = Color(0xFF101014); // iron
  static const Color _surface = Color(0xFF16161C); // steel
  static const Color _surfaceVariant = Color(0xFF1A1A20); // steel light
  static const Color _primary = Color(0xFFC1121F); // blood
  static const Color _secondary = Color(0xFF7B9DC4); // steel blue
  static const Color _tertiary = Color(0xFFC9A227); // war gold
  static const Color _error = Color(0xFFC1121F); // blood
  static const Color _onBackground = Color(0xFFD8D3C8); // bone
  static const Color _onSurface = Color(0xFFD8D3C8); // bone
  static const Color _onPrimary = Color(0xFFF5F1E8); // bone bright
  static const Color _divider = Color(0xFF1A1A20);

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        tertiary: _tertiary,
        error: _error,
        surface: _surface,
        onPrimary: _onPrimary,
        onSecondary: _onPrimary,
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
          return const TextStyle(color: Color(0xFF8A8F98), fontSize: 12);
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
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _divider, thickness: 1),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _onBackground),
        bodyMedium: TextStyle(color: _onBackground),
        bodySmall: TextStyle(color: Color(0xFF8A8F98)),
      ),
    );
  }
}
