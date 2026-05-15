import 'package:flutter/material.dart';

/// Synthwave '84 — The signature theme.
/// Deep space darkness, neon magenta, cyan glow, amber accents.
class Synthwave84Theme {
  static const Color _background = Color(0xFF050510);
  static const Color _surface = Color(0xFF0E0E24);
  static const Color _surfaceVariant = Color(0xFF16163A);
  static const Color _primary = Color(0xFFFF00FF);
  static const Color _secondary = Color(0xFF00D4FF);
  static const Color _error = Color(0xFFFF3333);
  static const Color _onBackground = Color(0xFFE8E8FF);
  static const Color _onSurface = Color(0xFFD0D0F0);
  static const Color _onPrimary = Color(0xFF000000);
  static const Color _onSecondary = Color(0xFF000000);
  static const Color _divider = Color(0xFF2A2A50);

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        error: _error,
        surface: _surface,
        onPrimary: _onPrimary,
        onSecondary: _onSecondary,
        onSurface: _onSurface,
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: _background,

      // AppBar
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

      // Cards
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _primary, width: 0.5),
        ),
        shadowColor: _primary.withValues(alpha: 0.3),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: Color(0xFF666688),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _primary, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF666688), fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF666688), size: 24);
        }),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _error),
        ),
        labelStyle: const TextStyle(color: Color(0xFF8888AA)),
        hintStyle: const TextStyle(color: Color(0xFF555577)),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          elevation: 4,
          shadowColor: _primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _secondary,
          side: const BorderSide(color: _secondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _secondary),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return const Color(0xFF555577);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withValues(alpha: 0.3);
          }
          return const Color(0xFF2A2A50);
        }),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: Color(0xFF2A2A50),
        thumbColor: _primary,
        overlayColor: Color(0x1AFF00FF),
        valueIndicatorColor: _primary,
        valueIndicatorTextStyle: TextStyle(color: Colors.black),
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: Color(0xFF2A2A50),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        selectedColor: _primary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: _onSurface),
        side: const BorderSide(color: _divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: _divider, thickness: 0.5),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceVariant,
        contentTextStyle: const TextStyle(color: _onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Tab bar
      tabBarTheme: const TabBarThemeData(
        labelColor: _secondary,
        unselectedLabelColor: Color(0xFF666688),
        indicatorColor: _secondary,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.0),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w300,
        ),
        displayMedium: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _onBackground,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: _onSurface, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: _onSurface, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(
          color: Color(0xFF8888AA),
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: _secondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF8888AA),
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF666688),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
