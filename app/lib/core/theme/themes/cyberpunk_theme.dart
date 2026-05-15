import 'package:flutter/material.dart';

/// Cyberpunk — Matrix green, electric blue, chrome. Aggressive contrast.
class CyberpunkTheme {
  static const Color _background = Color(0xFF0A0A0A);
  static const Color _surface = Color(0xFF151515);
  static const Color _surfaceVariant = Color(0xFF1F1F2A);
  static const Color _primary = Color(0xFF00FF41);
  static const Color _secondary = Color(0xFF003BFF);
  static const Color _accent = Color(0xFFFFD700);
  static const Color _error = Color(0xFFFF3333);
  static const Color _onBackground = Color(0xFFD0D0D0);
  static const Color _onSurface = Color(0xFFB0B0B0);
  static const Color _divider = Color(0xFF2A2A2A);

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
        onSecondary: Colors.white,
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
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: _primary, width: 0.5),
        ),
        shadowColor: _primary.withValues(alpha: 0.2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: _primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(color: Color(0xFF555555), fontSize: 12);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF558855)),
        hintStyle: const TextStyle(color: Color(0xFF335533)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: _primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: const TextStyle(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return const Color(0xFF555555);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withValues(alpha: 0.3);
          }
          return const Color(0xFF2A2A2A);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: Color(0xFF1A1A1A),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        selectedColor: _primary.withValues(alpha: 0.2),
        side: const BorderSide(color: _primary, width: 0.5),
        labelStyle: const TextStyle(color: _onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      dividerTheme: const DividerThemeData(color: _divider),
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: _primary, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceVariant,
        contentTextStyle: const TextStyle(color: _primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        behavior: SnackBarBehavior.floating,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _primary,
        unselectedLabelColor: Color(0xFF555555),
        indicatorColor: _primary,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2.0),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _primary, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: _primary, fontWeight: FontWeight.w600),
        displaySmall: TextStyle(color: _primary, fontWeight: FontWeight.w500),
        headlineLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
        headlineMedium: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: _onSurface, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: _onSurface, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(
          color: Color(0xFF707070),
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: _primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF707070),
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF505050),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
