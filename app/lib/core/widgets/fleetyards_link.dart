import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the FleetYards.net site in the default browser
Future<void> openFleetYards({String? path}) async {
  final url = path != null
      ? 'https://fleetyards.net$path'
      : 'https://fleetyards.net';
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Browser not available — silently fail
  }
}

/// A styled link button to FleetYards.net
class FleetYardsLink extends StatelessWidget {
  final String? path;
  final String label;
  final bool compact;

  const FleetYardsLink({
    super.key,
    this.path,
    this.label = 'FleetYards.net',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return InkWell(
        onTap: () => openFleetYards(path: path),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.open_in_new, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => openFleetYards(path: path),
      icon: const Icon(Icons.open_in_new, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

/// Full-width FleetYards banner card for screens that need a prominent link
class FleetYardsBanner extends StatelessWidget {
  final String? path;
  final String title;
  final String subtitle;

  const FleetYardsBanner({
    super.key,
    this.path,
    this.title = 'FleetYards.net',
    this.subtitle = 'Browse the complete Star Citizen ship database, compare stats, and plan your fleet.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.open_in_new,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FleetYardsLink(path: path, compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
