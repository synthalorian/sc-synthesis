import 'package:flutter/material.dart';

/// Manufacturer color schemes for ship visuals.
/// Each manufacturer gets a distinct gradient + accent color.
class ManufacturerStyle {
  final String name;
  final Color primary;
  final Color secondary;
  final IconData icon;

  const ManufacturerStyle({
    required this.name,
    required this.primary,
    required this.secondary,
    this.icon = Icons.rocket_outlined,
  });

  static const Map<String, ManufacturerStyle> _styles = {
    'origin jumpworks': ManufacturerStyle(
      name: 'Origin',
      primary: Color(0xFFE0E0FF),
      secondary: Color(0xFF6B6BFF),
      icon: Icons.diamond_outlined,
    ),
    'aegis dynamics': ManufacturerStyle(
      name: 'Aegis',
      primary: Color(0xFFFF4444),
      secondary: Color(0xFF8B0000),
      icon: Icons.shield_outlined,
    ),
    'anvil aerospace': ManufacturerStyle(
      name: 'Anvil',
      primary: Color(0xFFFFD700),
      secondary: Color(0xFFB8860B),
      icon: Icons.shield_outlined,
    ),
    'drake interplanetary': ManufacturerStyle(
      name: 'Drake',
      primary: Color(0xFFFF8C00),
      secondary: Color(0xFF8B4513),
      icon: Icons.build_outlined,
    ),
    'misc': ManufacturerStyle(
      name: 'MISC',
      primary: Color(0xFF00BFFF),
      secondary: Color(0xFF00688B),
      icon: Icons.directions_boat_outlined,
    ),
    'crusader industries': ManufacturerStyle(
      name: 'Crusader',
      primary: Color(0xFF00FFFF),
      secondary: Color(0xFF008B8B),
      icon: Icons.flight_outlined,
    ),
    'roberts space industries': ManufacturerStyle(
      name: 'RSI',
      primary: Color(0xFFC0C0C0),
      secondary: Color(0xFF4A4A4A),
      icon: Icons.stars_outlined,
    ),
    'tumbril': ManufacturerStyle(
      name: 'Tumbril',
      primary: Color(0xFFFF69B4),
      secondary: Color(0xFF8B0060),
      icon: Icons.speed_outlined,
    ),
    'argo astronautics': ManufacturerStyle(
      name: 'Argo',
      primary: Color(0xFFFFD700),
      secondary: Color(0xFFDAA520),
      icon: Icons.handyman_outlined,
    ),
    'consolidated outland': ManufacturerStyle(
      name: 'CNOU',
      primary: Color(0xFF7CFC00),
      secondary: Color(0xFF228B22),
      icon: Icons.explore_outlined,
    ),
    'esperia': ManufacturerStyle(
      name: 'Esperia',
      primary: Color(0xFF9932CC),
      secondary: Color(0xFF4B0082),
      icon: Icons.bug_report_outlined,
    ),
    'mirai': ManufacturerStyle(
      name: 'Mirai',
      primary: Color(0xFFFF4500),
      secondary: Color(0xFF8B2500),
      icon: Icons.rocket_outlined,
    ),
    'greycat industrial': ManufacturerStyle(
      name: 'Greycat',
      primary: Color(0xFFA9A9A9),
      secondary: Color(0xFF555555),
      icon: Icons.precision_manufacturing_outlined,
    ),
    'aopoa': ManufacturerStyle(
      name: 'Aopoa',
      primary: Color(0xFF00FF7F),
      secondary: Color(0xFF006400),
      icon: Icons.language_outlined,
    ),
    'kruger intergalactic': ManufacturerStyle(
      name: 'Kruger',
      primary: Color(0xFF4169E1),
      secondary: Color(0xFF00008B),
      icon: Icons.radar_outlined,
    ),
    'banu': ManufacturerStyle(
      name: 'Banu',
      primary: Color(0xFFFF1493),
      secondary: Color(0xFF8B0060),
      icon: Icons.store_outlined,
    ),
    'gatac manufacture': ManufacturerStyle(
      name: 'Gatac',
      primary: Color(0xFF00CED1),
      secondary: Color(0xFF008B8B),
      icon: Icons.hexagon_outlined,
    ),
    'vanduul': ManufacturerStyle(
      name: 'Vanduul',
      primary: Color(0xFFFF0000),
      secondary: Color(0xFF4A0000),
      icon: Icons.dangerous_outlined,
    ),
  };

  static ManufacturerStyle forName(String manufacturer) {
    final key = manufacturer.toLowerCase().trim();
    return _styles.entries
        .firstWhere(
          (e) => key.contains(e.key),
          orElse: () => const MapEntry('unknown', ManufacturerStyle(
            name: 'Unknown',
            primary: Color(0xFF888888),
            secondary: Color(0xFF444444),
          )),
        )
        .value;
  }

  LinearGradient gradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary.withValues(alpha: 0.2), secondary.withValues(alpha: 0.35)],
    );
  }

  BoxDecoration decoration({double radius = 10}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary.withValues(alpha: 0.15), secondary.withValues(alpha: 0.25)],
      ),
      border: Border.all(
        color: primary.withValues(alpha: 0.3),
        width: 1.5,
      ),
    );
  }
}

/// A ship avatar/image widget that uses manufacturer colors.
/// No actual image files needed — purely code-generated, always offline.
class ShipAvatar extends StatelessWidget {
  final String manufacturer;
  final double size;
  final String? shipName;

  const ShipAvatar({
    super.key,
    required this.manufacturer,
    this.size = 44,
    this.shipName,
  });

  @override
  Widget build(BuildContext context) {
    final style = ManufacturerStyle.forName(manufacturer);

    return Container(
      width: size,
      height: size,
      decoration: style.decoration(radius: size * 0.22),
      child: Icon(
        style.icon,
        size: size * 0.5,
        color: style.primary,
      ),
    );
  }
}

/// Full ship hero image for the detail screen — gradient banner with ship info.
class ShipHero extends StatelessWidget {
  final String name;
  final String manufacturer;
  final String? priceLabel;
  final double height;

  const ShipHero({
    super.key,
    required this.name,
    required this.manufacturer,
    this.priceLabel,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ManufacturerStyle.forName(manufacturer);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.secondary.withValues(alpha: 0.4),
            style.primary.withValues(alpha: 0.15),
            theme.colorScheme.surface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border(
          bottom: BorderSide(
            color: style.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Manufacturer icon watermark
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              style.icon,
              size: 120,
              color: style.primary.withValues(alpha: 0.06),
            ),
          ),
          // Ship info
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: style.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: style.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: style.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        style.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: style.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (priceLabel != null && priceLabel!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        priceLabel!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
