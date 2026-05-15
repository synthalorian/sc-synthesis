import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sc_synthesis/core/data/rust_database_service.dart';
import 'package:sc_synthesis/core/theme/app_theme.dart';
import 'package:sc_synthesis/core/theme/widgets/theme_selector.dart';
import 'package:sc_synthesis/core/widgets/buy_me_a_coffee.dart';
import 'package:sc_synthesis/core/widgets/fleetyards_link.dart';
import 'package:sc_synthesis/features/ships/ship_compare_screen.dart';

/// Settings / About screen — replaces the old Profile/Login tab.
/// Shows app info, database stats, external links, and theme selector access.
class SettingsScreen extends StatelessWidget {
  final VoidCallback? onTapTheme;
  const SettingsScreen({super.key, this.onTapTheme});

  void _openThemeSelector(BuildContext context) {
    Navigator.of(context).push<AppThemeType>(
      MaterialPageRoute(
        builder: (_) => ThemeSelectorScreen(
          currentType: ThemeManager.instance.currentType,
        ),
      ),
    ).then((result) {
      if (result != null) {
        ThemeManager.instance.setTheme(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rustDb = RustDatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SC Synthesis'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _openThemeSelector(context),
            tooltip: 'Theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── App header ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SC Synthesis',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v0.2.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A Star Citizen companion app',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Local Database stats ─────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local Database',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<int>(
                    future:
                        rustDb.isInitialized ? rustDb.getShipCount() : Future.value(0),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 238;
                      return Row(
                        children: [
                          _statTile(theme, Icons.rocket_outlined,
                              '$count ships', 'Bundled offline'),
                          const SizedBox(width: 16),
                          _statTile(theme, Icons.storage_outlined,
                              'SQLite', 'Local database'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statTile(theme, Icons.palette_outlined,
                          '${AppThemeType.values.length} themes', 'Visual styles'),
                      const SizedBox(width: 16),
                      _statTile(theme, Icons.flight_outlined,
                          '100% offline', 'No server needed'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Resources ─────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resources',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.open_in_new,
                        color: theme.colorScheme.primary),
                    title: const Text('FleetYards.net'),
                    subtitle: const Text(
                        'Full ship database, compare, community'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openFleetYards(),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  ListTile(
                    leading: Icon(Icons.code,
                        color: theme.colorScheme.primary),
                    title: const Text('GitHub Repository'),
                    subtitle: const Text(
                        'Source code, issues, contributions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final uri = Uri.parse(
                          'https://github.com/synthalorian/sc-synthesis');
                      try {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (_) {}
                    },
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  ListTile(
                    leading: Icon(Icons.compare_arrows,
                        color: theme.colorScheme.primary),
                    title: const Text('Ship Comparison'),
                    subtitle: const Text(
                        'Compare ships side by side with stat bars'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ShipCompareScreen()),
                    ),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Buy Me a Coffee ───────────────────────────────────────
          BuyMeACoffeeButton(),
          const SizedBox(height: 16),

          // ── Theme selector ────────────────────────────────────────
          Card(
            child: ListTile(
              leading: Icon(Icons.palette_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Change Theme'),
              subtitle: const Text('Pick your visual style'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openThemeSelector(context),
            ),
          ),
          const SizedBox(height: 32),

          // ── Footer ────────────────────────────────────────────────
          Center(
            child: Text(
              'Made with \u{1F3B9}\u{1F99E} by synthalorian',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Star Citizen is a registered trademark of Cloud Imperium Games',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statTile(
      ThemeData theme, IconData icon, String title, String subtitle) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
              Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
