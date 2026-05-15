import 'package:flutter/material.dart';

/// OutRun — Hot pink, bright cyan, sunset energy
class OutRunTheme {
  static const Color _background = Color(0xFF0D0D1A);
  static const Color _surface = Color(0xFF1A1A2E);
  static const Color _surfaceVariant = Color(0xFF25254A);
  static const Color _primary = Color(0xFFFF007F);
  static const Color _secondary = Color(0xFF00E5FF);
  static const Color _accent = Color(0xFFFF6B35);
  static const Color _error = Color(0xFFFF1744);
  static const Color _onBackground = Color(0xFFE8E0F0);
  static const Color _onSurface = Color(0xFFD0C8E0);
  static const Color _divider = Color(0xFF2A2A50);

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
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _onSurface,
      ),
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _secondary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _secondary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _primary, width: 0.5),
        ),
        shadowColor: _primary.withValues(alpha: 0.3),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _primary, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF666688), fontSize: 12);
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
          borderSide: const BorderSide(color: _secondary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _secondary,
          side: const BorderSide(color: _secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        selectedColor: _primary.withValues(alpha: 0.2),
        side: const BorderSide(color: _divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: _divider),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: Color(0xFF666688),
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(color: _onBackground),
        bodyLarge: TextStyle(color: _onSurface),
        bodyMedium: TextStyle(color: _onSurface),
        labelLarge: TextStyle(
          color: _secondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
