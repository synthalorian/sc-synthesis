import 'package:flutter/material.dart';

/// Vaporwave — Dreamy pastels: lavender, aqua, soft pink
class VaporwaveTheme {
  static const Color _background = Color(0xFF1A1A2E);
  static const Color _surface = Color(0xFF252540);
  static const Color _surfaceVariant = Color(0xFF30305A);
  static const Color _primary = Color(0xFFB57EDC);
  static const Color _secondary = Color(0xFF7EC8E3);
  static const Color _accent = Color(0xFFF4A7BB);
  static const Color _error = Color(0xFFEF9A9A);
  static const Color _onBackground = Color(0xFFE8E0F5);
  static const Color _onSurface = Color(0xFFD0C8E8);
  static const Color _divider = Color(0xFF3A3A60);

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        tertiary: _accent,
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
        titleTextStyle: TextStyle(
          color: _primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3A3A60), width: 0.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _primary, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF7070AA), fontSize: 12);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF8888AA)),
        hintStyle: const TextStyle(color: Color(0xFF555588)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _secondary,
          side: const BorderSide(color: _secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        selectedColor: _accent.withValues(alpha: 0.2),
        side: const BorderSide(color: _divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _divider,
        thumbColor: _accent,
        overlayColor: _primary.withValues(alpha: 0.1),
      ),
      dividerTheme: const DividerThemeData(color: _divider),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w300,
        ),
        headlineMedium: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: _onSurface, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: _onSurface, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
          color: _primary,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
