import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/api/auth_manager.dart';
import 'package:sc_synthesis/core/theme/app_theme.dart';
import 'package:sc_synthesis/core/theme/widgets/theme_selector.dart';
import 'package:sc_synthesis/core/data/rust_database_service.dart';
import 'package:sc_synthesis/features/auth/auth_screen.dart';
import 'package:sc_synthesis/features/fleet/fleet_screen.dart';
import 'package:sc_synthesis/features/ships/ship_list_screen.dart';

class ScSynthesisApp extends StatefulWidget {
  const ScSynthesisApp({super.key});

  @override
  State<ScSynthesisApp> createState() => ScSynthesisAppState();
}

class ScSynthesisAppState extends State<ScSynthesisApp> {
  late final ThemeManager _themeManager;
  late final AuthManager _authManager;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager()..addListener(_onThemeChanged);
    _authManager = AuthManager()..addListener(_onAuthChanged);
    // Initialize Rust backend — opens SQLite DB, seeds from bundled data
    RustDatabaseService().init();
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    _authManager.removeListener(_onAuthChanged);
    _authManager.dispose();
    _themeManager.dispose();
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});
  void _onAuthChanged() => setState(() {});

  void _openThemeSelector() async {
    final result = await Navigator.of(context).push<AppThemeType>(
      MaterialPageRoute(
        builder: (_) => ThemeSelectorScreen(
          currentType: _themeManager.currentType,
        ),
      ),
    );
    if (result != null && mounted) {
      _themeManager.setTheme(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const ValueKey('sc-synthesis'),
      title: 'SC:Synthesis',
      debugShowCheckedModeBanner: false,
      theme: _themeManager.currentTheme,
      home: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: IndexedStack(
            key: ValueKey('tab-$_currentTab'),
            index: _currentTab,
            children: [
              FleetScreen(
                authManager: _authManager,
                onTapTheme: _openThemeSelector,
              ),
              ShipListScreen(
                onTapTheme: _openThemeSelector,
              ),
              AuthScreen(
                authManager: _authManager,
                onTapTheme: _openThemeSelector,
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (index) {
            setState(() => _currentTab = index);
          },
          animationDuration: const Duration(milliseconds: 400),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.rocket_launch_outlined),
              selectedIcon: Icon(Icons.rocket_launch),
              label: 'Fleet',
            ),
            NavigationDestination(
              icon: Icon(Icons.scanner_outlined),
              selectedIcon: Icon(Icons.scanner),
              label: 'Ships',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
