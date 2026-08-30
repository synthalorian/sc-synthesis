import 'package:flutter/material.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';
import 'themes/synthwave84_theme.dart';
import 'themes/outrun_theme.dart';
import 'themes/vaporwave_theme.dart';
import 'themes/cyberpunk_theme.dart';
import 'themes/blackshield_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available theme identifiers
/// NOTE: append-only — persisted by index, never reorder or insert.
enum AppThemeType { dark, light, synthwave84, outrun, vaporwave, cyberpunk, blackshield }

extension AppThemeTypeExtension on AppThemeType {
  String get displayName {
    switch (this) {
      case AppThemeType.dark:
        return 'Dark Core';
      case AppThemeType.light:
        return 'Light Core';
      case AppThemeType.synthwave84:
        return 'Synthwave \'84';
      case AppThemeType.outrun:
        return 'OutRun';
      case AppThemeType.vaporwave:
        return 'Vaporwave';
      case AppThemeType.cyberpunk:
        return 'Cyberpunk';
      case AppThemeType.blackshield:
        return 'Blackshield';
    }
  }

  String get description {
    switch (this) {
      case AppThemeType.dark:
        return 'Clean, professional dark mode. Easy on the eyes.';
      case AppThemeType.light:
        return 'Clean, professional light mode. High readability.';
      case AppThemeType.synthwave84:
        return 'Neon magenta, cyan glow, and deep space darkness. The original.';
      case AppThemeType.outrun:
        return 'Hot pink and bright cyan. Sunset-hued saturation.';
      case AppThemeType.vaporwave:
        return 'Dreamy pastels — lavender, aqua, and soft pink.';
      case AppThemeType.cyberpunk:
        return 'Matrix green, electric blue, and chrome. High contrast.';
      case AppThemeType.blackshield:
        return 'Steel and blood. Forged for the mercenary who answers to no crown.';
    }
  }

  /// Uniquely identifiable icon for each theme
  IconData get icon {
    switch (this) {
      case AppThemeType.dark:
        return Icons.dark_mode;
      case AppThemeType.light:
        return Icons.light_mode;
      case AppThemeType.synthwave84:
        return Icons.wb_sunny_outlined;
      case AppThemeType.outrun:
        return Icons.speed;
      case AppThemeType.vaporwave:
        return Icons.water_drop;
      case AppThemeType.cyberpunk:
        return Icons.flash_on;
      case AppThemeType.blackshield:
        return Icons.shield;
    }
  }

  ThemeData get themeData {
    switch (this) {
      case AppThemeType.dark:
        return DarkTheme.build();
      case AppThemeType.light:
        return LightTheme.build();
      case AppThemeType.synthwave84:
        return Synthwave84Theme.build();
      case AppThemeType.outrun:
        return OutRunTheme.build();
      case AppThemeType.vaporwave:
        return VaporwaveTheme.build();
      case AppThemeType.cyberpunk:
        return CyberpunkTheme.build();
      case AppThemeType.blackshield:
        return BlackshieldTheme.build();
    }
  }

  Color get previewColor {
    switch (this) {
      case AppThemeType.dark:
        return const Color(0xFF4FC3F7);
      case AppThemeType.light:
        return const Color(0xFF0288D1);
      case AppThemeType.synthwave84:
        return const Color(0xFFFF00FF);
      case AppThemeType.outrun:
        return const Color(0xFFFF007F);
      case AppThemeType.vaporwave:
        return const Color(0xFFB57EDC);
      case AppThemeType.cyberpunk:
        return const Color(0xFF00FF41);
      case AppThemeType.blackshield:
        return const Color(0xFFC1121F);
    }
  }
}

/// Manages the active theme and persists the choice
class ThemeManager extends ChangeNotifier {
  static ThemeManager? _instance;
  static ThemeManager get instance {
    _instance ??= ThemeManager._();
    return _instance!;
  }

  static const String _themeKey = 'app_theme_type';

  AppThemeType _currentType = AppThemeType.blackshield;
  ThemeData? _cachedTheme;
  late SharedPreferences _prefs;

  AppThemeType get currentType => _currentType;
  ThemeData get currentTheme => _cachedTheme ?? _currentType.themeData;

  ThemeManager._() {
    _loadTheme();
  }

  @pragma('vm:prefer-inline')
  factory ThemeManager() => instance;

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final index = _prefs.getInt(_themeKey);
    if (index != null && index >= 0 && index < AppThemeType.values.length) {
      _currentType = AppThemeType.values[index];
      _cachedTheme = _currentType.themeData;
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeType type) async {
    if (_currentType == type) return;
    _currentType = type;
    _cachedTheme = type.themeData;
    await _prefs.setInt(_themeKey, type.index);
    notifyListeners();
  }
}
