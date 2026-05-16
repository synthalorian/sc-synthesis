import 'dart:math';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// Type of location in the Stanton system.
enum _LocationType { planet, station, restStop, lagrange }

/// A named point of interest on the starmap with display metadata.
class _StarmapLocation {
  final String name;
  final _LocationType type;
  final List<String> services;
  final String description;

  const _StarmapLocation({
    required this.name,
    required this.type,
    this.services = const [],
    this.description = '',
  });
}

// ---------------------------------------------------------------------------
// Location definitions
// ---------------------------------------------------------------------------

const _kPlanets = <_StarmapLocation>[
  _StarmapLocation(
    name: 'Hurston',
    type: _LocationType.planet,
    services: ['Ship Spawn', 'Cargo', 'Habitation', 'Shopping'],
    description:
        'The corporate homeworld of Hurston Dynamics. A polluted industrial '
        'world known for its massive manufacturing facilities and authoritarian '
        'governance.',
  ),
  _StarmapLocation(
    name: 'ArcCorp',
    type: _LocationType.planet,
    services: ['Ship Spawn', 'Cargo', 'Habitation', 'Shopping', 'Admin'],
    description:
        'A fully urbanized planet covered entirely by a single sprawling '
        'cityscape. Home to ArcCorp, one of the mega-corporations of the '
        'United Empire of Earth.',
  ),
  _StarmapLocation(
    name: 'Crusader',
    type: _LocationType.planet,
    services: ['Ship Spawn', 'Cargo', 'Refueling', 'Habitation'],
    description:
        'A gas giant with a breathable atmosphere layer. Home to Crusader '
        'Industries and the floating city of Orison suspended in its '
        'clouds.',
  ),
  _StarmapLocation(
    name: 'microTech',
    type: _LocationType.planet,
    services: ['Ship Spawn', 'Cargo', 'Habitation', 'Shopping', 'Mining'],
    description:
        'A cold, snow-covered world owned by microTech. Features the '
        'sleek, modern city of New Babbage built into a glacial valley.',
  ),
];

const _kStations = <_StarmapLocation>[
  _StarmapLocation(
    name: 'Everus Harbor',
    type: _LocationType.station,
    services: ['Ship Spawn', 'Refueling', 'Repair', 'Cargo', 'Habitation'],
    description:
        'The orbital station serving Hurston. A major transit hub '
        'for goods leaving the surface factories.',
  ),
  _StarmapLocation(
    name: 'Baijini Point',
    type: _LocationType.station,
    services: ['Ship Spawn', 'Refueling', 'Repair', 'Cargo', 'Habitation'],
    description:
        'The orbital station serving ArcCorp. A busy waypoint for '
        'the endless stream of orbital traffic above Area18.',
  ),
  _StarmapLocation(
    name: 'Seraphim Station',
    type: _LocationType.station,
    services: ['Ship Spawn', 'Refueling', 'Repair', 'Cargo', 'Habitation'],
    description:
        'The orbital station serving Crusader. Provides safe harbor '
        'above the turbulent gas giant.',
  ),
  _StarmapLocation(
    name: 'Port Tressler',
    type: _LocationType.station,
    services: ['Ship Spawn', 'Refueling', 'Repair', 'Cargo', 'Habitation'],
    description:
        'The orbital station serving microTech. A gleaming outpost '
        'in orbit above the frozen world.',
  ),
];

const _kRestStops = <_StarmapLocation>[
  _StarmapLocation(
    name: 'R&R CRU-L1',
    type: _LocationType.restStop,
    services: ['Refueling', 'Repair', 'Habitation'],
    description:
        'A standard Rest & Relax station at the L1 Lagrange point '
        'between Crusader and ArcCorp.',
  ),
  _StarmapLocation(
    name: 'R&R HUR-L2',
    type: _LocationType.restStop,
    services: ['Refueling', 'Repair', 'Habitation'],
    description:
        'A Rest & Relax station at the L2 Lagrange point '
        'near Hurston.',
  ),
];

const _kLagrangePoints = <_StarmapLocation>[
  _StarmapLocation(
    name: 'HUR-L1',
    type: _LocationType.lagrange,
    description:
        'L1 Lagrange point between Hurston and ArcCorp.',
  ),
  _StarmapLocation(
    name: 'ARC-L1',
    type: _LocationType.lagrange,
    services: ['Cargo'],
    description:
        'L1 Lagrange point between ArcCorp and Crusader.',
  ),
  _StarmapLocation(
    name: 'CRU-L2',
    type: _LocationType.lagrange,
    description:
        'L2 Lagrange point between Crusader and microTech.',
  ),
  _StarmapLocation(
    name: 'MIC-L1',
    type: _LocationType.lagrange,
    description:
        'L1 Lagrange point between microTech and Hurston.',
  ),
];

// ---------------------------------------------------------------------------
// Orbital & visual constants
// ---------------------------------------------------------------------------

/// Orbital configuration for each planet.
class _OrbitConfig {
  final double radiusFraction;
  final double angleDeg;
  final Color color;
  final double markerRadius;

  const _OrbitConfig({
    required this.radiusFraction,
    required this.angleDeg,
    required this.color,
    this.markerRadius = 14,
  });
}

const _kOrbitConfigs = <_OrbitConfig>[
  // Hurston
  _OrbitConfig(
    radiusFraction: 0.18,
    angleDeg: 30,
    color: Color(0xFF39FF14),
    markerRadius: 14,
  ),
  // ArcCorp
  _OrbitConfig(
    radiusFraction: 0.32,
    angleDeg: 120,
    color: Color(0xFFFF6B35),
    markerRadius: 14,
  ),
  // Crusader — largest
  _OrbitConfig(
    radiusFraction: 0.46,
    angleDeg: 210,
    color: Color(0xFF4FC3F7),
    markerRadius: 20,
  ),
  // microTech — farthest
  _OrbitConfig(
    radiusFraction: 0.60,
    angleDeg: 300,
    color: Color(0xFF00FFFF),
    markerRadius: 14,
  ),
];

// Station angular offsets from their parent planet
const _kStationOffsets = <double>[
  -25, // Everus Harbor from Hurston
  20, // Baijini Point from ArcCorp
  -30, // Seraphim Station from Crusader
  25, // Port Tressler from microTech
];

// Rest stop positions as (radiusFraction, angleDeg)
const _kRestStopPositions = <(double, double)>[
  (0.39, 165), // CRU-L1 between ArcCorp and Crusader
  (0.24, 350), // HUR-L2 near Hurston
];

// Lagrange point positions
const _kLagrangePositions = <(double, double)>[
  (0.25, 75), // HUR-L1
  (0.39, 165), // ARC-L1
  (0.53, 255), // CRU-L2
  (0.39, 345), // MIC-L1
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Offset _polarToCartesian(Offset center, double radius, double angleDeg) {
  final rad = angleDeg * pi / 180;
  return Offset(
    center.dx + radius * cos(rad),
    center.dy + radius * sin(rad),
  );
}

/// Random seeded star positions generated once.
List<Offset> _generateStars(int count, Size size) {
  final rng = Random(42);
  return List.generate(count, (_) {
    return Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
  });
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

/// A full-screen interactive map of the Stanton star system with a synthwave
/// aesthetic: dark background, neon orbits, glowing markers, and scan-line
/// effects. Tap any location to see details in a bottom sheet.
///
/// Supports pinch-to-zoom via [InteractiveViewer].
class StantonMapScreen extends StatefulWidget {
  const StantonMapScreen({super.key});

  @override
  State<StantonMapScreen> createState() => _StantonMapScreenState();
}

class _StantonMapScreenState extends State<StantonMapScreen> {
  // Cache star positions so they don't flicker on repaint
  List<Offset>? _cachedStars;
  Size? _lastStarSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stanton System'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Legend',
            onPressed: () => _showLegend(context, theme),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use the larger dimension as a square canvas so there's room to
          // zoom and pan without hitting edges immediately.
          final baseSize =
              max(constraints.maxWidth, constraints.maxHeight).ceilToDouble();
          final canvasSize = Size(baseSize, baseSize);

          // Lazily generate stars for this size
          if (_cachedStars == null || _lastStarSize != canvasSize) {
            _cachedStars = _generateStars(120, canvasSize);
            _lastStarSize = canvasSize;
          }

          // Pre-compute all screen positions for hit-testing
          final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
          final orbitScale =
              min(canvasSize.width, canvasSize.height) / 2;

          // Planets
          final planetPositions = <Offset>[];
          final allPositions = <_StarmapLocation, Offset>{};

          for (final config in _kOrbitConfigs) {
            final pos = _polarToCartesian(
              center,
              config.radiusFraction * orbitScale,
              config.angleDeg,
            );
            planetPositions.add(pos);
          }

          for (int i = 0; i < _kPlanets.length; i++) {
            allPositions[_kPlanets[i]] = planetPositions[i];
          }

          // Stations — offset from their parent planet
          for (int i = 0; i < _kStations.length; i++) {
            final idx = i < _kStations.length ? i : 0;
            final parentConfig = _kOrbitConfigs[idx];
            final stationAngle = parentConfig.angleDeg + _kStationOffsets[idx];
            final r = parentConfig.radiusFraction * orbitScale + 30;
            final pos = _polarToCartesian(center, r, stationAngle);
            allPositions[_kStations[i]] = pos;
          }

          // Rest stops
          for (int i = 0; i < _kRestStops.length && i < _kRestStopPositions.length; i++) {
            final (rFrac, aDeg) = _kRestStopPositions[i];
            final pos = _polarToCartesian(center, rFrac * orbitScale, aDeg);
            allPositions[_kRestStops[i]] = pos;
          }

          // Lagrange points
          for (int i = 0; i < _kLagrangePoints.length && i < _kLagrangePositions.length; i++) {
            final (rFrac, aDeg) = _kLagrangePositions[i];
            final pos = _polarToCartesian(center, rFrac * orbitScale, aDeg);
            allPositions[_kLagrangePoints[i]] = pos;
          }

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(200),
            child: GestureDetector(
              onTapUp: (details) {
                final tapPos = details.localPosition;
                for (final entry in allPositions.entries) {
                  final loc = entry.key;
                  final pos = entry.value;
                  final dist = (tapPos - pos).distance;
                  final hitRadius = loc.type == _LocationType.planet ? 30.0 : 22.0;
                  if (dist <= hitRadius) {
                    _showLocationDetail(context, theme, loc);
                    return;
                  }
                }
              },
              child: CustomPaint(
                size: canvasSize,
                painter: _StantonMapPainter(
                  stars: _cachedStars!,
                  orbitScale: orbitScale,
                  center: center,
                  planetPositions: planetPositions,
                  allPositions: allPositions,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Legend dialog
  // -----------------------------------------------------------------------
  void _showLegend(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.map, color: theme.colorScheme.secondary, size: 22),
              const SizedBox(width: 10),
              const Text('Stanton System Map'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendEntry(theme, 'Planet', Icons.circle,
                    const Color(0xFF4FC3F7), 'Large glowing marker'),
                const SizedBox(height: 8),
                _legendEntry(theme, 'Station', Icons.lens,
                    const Color(0xFF8888AA), 'Medium dot near planet'),
                const SizedBox(height: 8),
                _legendEntry(theme, 'Rest Stop', Icons.lens,
                    const Color(0xFFAAAAAA), 'Small dot at R&R points'),
                const SizedBox(height: 8),
                _legendEntry(theme, 'Lagrange', Icons.lens,
                    const Color(0xFF666688), 'Tiny dot at L-points'),
                const SizedBox(height: 16),
                Text(
                  'Tap any marker to view details about the location.\n'
                  'Pinch to zoom in / out.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _legendEntry(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    String description,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Bottom sheet
  // -----------------------------------------------------------------------
  void _showLocationDetail(
    BuildContext context,
    ThemeData theme,
    _StarmapLocation location,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final typeLabel = switch (location.type) {
          _LocationType.planet => 'Planet',
          _LocationType.station => 'Station',
          _LocationType.restStop => 'Rest Stop',
          _LocationType.lagrange => 'Lagrange Point',
        };

        final typeColor = switch (location.type) {
          _LocationType.planet => const Color(0xFF4FC3F7),
          _LocationType.station => const Color(0xFF8888AA),
          _LocationType.restStop => const Color(0xFFAAAAAA),
          _LocationType.lagrange => const Color(0xFF666688),
        };

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title + type badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: typeColor.withValues(alpha: 0.12),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          switch (location.type) {
                            _LocationType.planet => Icons.public,
                            _LocationType.station => Icons.satellite_alt,
                            _LocationType.restStop => Icons.local_gas_station,
                            _LocationType.lagrange => Icons.trip_origin,
                          },
                          color: typeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: typeColor.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                typeLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    location.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),

                  // Services chips
                  if (location.services.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Services',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: location.services.map((service) {
                        return _serviceChip(theme, service);
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                        side: BorderSide(
                          color: theme.colorScheme.secondary
                              .withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _serviceChip(ThemeData theme, String service) {
    final (IconData icon, Color color) = switch (service) {
      'Ship Spawn' => (Icons.rocket_launch, const Color(0xFF00D4FF)),
      'Refueling' => (Icons.local_gas_station, const Color(0xFFFFAA00)),
      'Repair' => (Icons.build, const Color(0xFFFF5555)),
      'Cargo' => (Icons.inventory_2, const Color(0xFF00FF41)),
      'Habitation' => (Icons.bed, const Color(0xFFB57EDC)),
      'Shopping' => (Icons.shopping_bag, const Color(0xFFFFD700)),
      'Admin' => (Icons.admin_panel_settings, const Color(0xFF4FC3F7)),
      'Mining' => (Icons.explore, const Color(0xFFFF8C00)),
      _ => (Icons.miscellaneous_services, const Color(0xFF8888AA)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            service,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

/// Paints the starfield, Stanton star, orbit rings, planet/station markers,
/// labels, and subtle scan-line effect.
class _StantonMapPainter extends CustomPainter {
  _StantonMapPainter({
    required this.stars,
    required this.orbitScale,
    required this.center,
    required this.planetPositions,
    required this.allPositions,
  });

  final List<Offset> stars;
  final double orbitScale;
  final Offset center;
  final List<Offset> planetPositions;
  final Map<_StarmapLocation, Offset> allPositions;

  // Pre-generate scan line positions so they stay stable across repaints
  static final List<double> _scanLines = List.generate(12, (i) {
    return 0.04 + (i * 0.085);
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStarfield(canvas, size);
    _drawStantonStar(canvas, size);
    _drawOrbits(canvas, size);
    _drawScanLines(canvas, size);
    _drawAllMarkers(canvas, size);
  }

  // -----------------------------------------------------------------------
  // Starfield
  // -----------------------------------------------------------------------
  void _drawStarfield(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    for (final star in stars) {
      canvas.drawCircle(star, 0.8, paint);
    }

    // Slightly brighter random stars
    final brightPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (int i = 0; i < stars.length; i += 5) {
      canvas.drawCircle(stars[i], 1.2, brightPaint);
    }
  }

  // -----------------------------------------------------------------------
  // Stanton star
  // -----------------------------------------------------------------------
  void _drawStantonStar(Canvas canvas, Size size) {
    final starRadius = orbitScale * 0.07;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFDD44).withValues(alpha: 0.3),
          const Color(0xFFFF8800).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: starRadius * 4));

    canvas.drawCircle(center, starRadius * 4, glowPaint);

    // Inner glow
    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFEE88).withValues(alpha: 0.6),
          const Color(0xFFFFAA00).withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: starRadius * 2));

    canvas.drawCircle(center, starRadius * 2, innerGlow);

    // Core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFFFEE66),
          const Color(0xFFFF9900),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: starRadius));

    canvas.drawCircle(center, starRadius, corePaint);
  }

  // -----------------------------------------------------------------------
  // Orbits
  // -----------------------------------------------------------------------
  void _drawOrbits(Canvas canvas, Size size) {
    for (final config in _kOrbitConfigs) {
      final radius = config.radiusFraction * orbitScale;

      // Glow layer
      final glowPaint = Paint()
        ..color = config.color.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, radius, glowPaint);

      // Main ring
      final ringPaint = Paint()
        ..color = config.color.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(center, radius, ringPaint);

      // Dashed overlay (manual dash)
      final dashPaint = Paint()
        ..color = config.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      _drawDashedCircle(canvas, center, radius, 12, 8, dashPaint);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset ctr,
    double radius,
    double dashLength,
    double gapLength,
    Paint paint,
  ) {
    const totalAngle = 2 * pi;
    bool drawing = true;
    double angle = 0;

    while (angle < totalAngle) {
      final segLen = drawing ? dashLength : gapLength;
      final segAngle = segLen / radius;
      final endAngle = min(angle + segAngle, totalAngle);

      if (drawing) {
        final path = Path();
        final start = Offset(
          ctr.dx + radius * cos(angle),
          ctr.dy + radius * sin(angle),
        );
        final end = Offset(
          ctr.dx + radius * cos(endAngle),
          ctr.dy + radius * sin(endAngle),
        );
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        canvas.drawPath(path, paint);
      }

      angle = endAngle;
      drawing = !drawing;
    }
  }

  // -----------------------------------------------------------------------
  // Scan lines
  // -----------------------------------------------------------------------
  void _drawScanLines(Canvas canvas, Size size) {
    final scanPaint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    for (final frac in _scanLines) {
      final y = size.height * frac;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }
  }

  // -----------------------------------------------------------------------
  // All markers
  // -----------------------------------------------------------------------
  void _drawAllMarkers(Canvas canvas, Size size) {
    // Planets
    for (int i = 0; i < _kPlanets.length && i < planetPositions.length; i++) {
      final config = _kOrbitConfigs[i];
      final pos = planetPositions[i];
      _drawPlanetMarker(canvas, pos, config);
    }

    // Stations
    for (int i = 0; i < _kStations.length; i++) {
      final pos = allPositions[_kStations[i]];
      if (pos != null) {
        _drawStationMarker(canvas, pos, _kStations[i].name);
      }
    }

    // Rest stops
    for (int i = 0; i < _kRestStops.length; i++) {
      final pos = allPositions[_kRestStops[i]];
      if (pos != null) {
        _drawRestStopMarker(canvas, pos, _kRestStops[i].name);
      }
    }

    // Lagrange points
    for (int i = 0; i < _kLagrangePoints.length; i++) {
      final pos = allPositions[_kLagrangePoints[i]];
      if (pos != null) {
        _drawLagrangeMarker(canvas, pos, _kLagrangePoints[i].name);
      }
    }
  }

  // -----------------------------------------------------------------------
  // Individual marker types
  // -----------------------------------------------------------------------
  void _drawPlanetMarker(Canvas canvas, Offset pos, _OrbitConfig config) {
    final r = config.markerRadius;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          config.color.withValues(alpha: 0.3),
          config.color.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 3));

    canvas.drawCircle(pos, r * 3, glowPaint);

    // Medium glow
    final midGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          config.color.withValues(alpha: 0.5),
          config.color.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 1.8));

    canvas.drawCircle(pos, r * 1.8, midGlow);

    // Solid core
    final corePaint = Paint()
      ..color = config.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, r, corePaint);

    // Bright highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4);

    canvas.drawCircle(
      Offset(pos.dx - r * 0.25, pos.dy - r * 0.25),
      r * 0.35,
      highlightPaint,
    );

    // Label
    _drawLabel(canvas, pos, _kPlanets[_kOrbitConfigs.indexOf(config)].name,
        config.color, r + 16);
  }

  void _drawStationMarker(Canvas canvas, Offset pos, String name) {
    const color = Color(0xFF8888AA);
    const r = 5.0;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 3));

    canvas.drawCircle(pos, r * 3, glowPaint);
    canvas.drawCircle(pos, r, Paint()..color = color);
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    _drawLabel(canvas, pos, name, color, r + 10);
  }

  void _drawRestStopMarker(Canvas canvas, Offset pos, String name) {
    const color = Color(0xFFAAAAAA);
    const r = 3.5;

    canvas.drawCircle(pos, r, Paint()..color = color);
    canvas.drawCircle(
      pos,
      r + 1.5,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    _drawLabel(canvas, pos, name, color, r + 8);
  }

  void _drawLagrangeMarker(Canvas canvas, Offset pos, String name) {
    const color = Color(0xFF666688);
    const r = 2.5;

    canvas.drawCircle(pos, r, Paint()..color = color);
    _drawLabel(canvas, pos, name, color, r + 6);
  }

  // -----------------------------------------------------------------------
  // Label drawing
  // -----------------------------------------------------------------------
  void _drawLabel(
    Canvas canvas,
    Offset pos,
    String text,
    Color color,
    double offsetY,
  ) {
    final textStyle = TextStyle(
      color: color.withValues(alpha: 0.85),
      fontSize: 10,
      fontWeight: FontWeight.w500,
      fontFamily: 'monospace',
    );

    final builder = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelPos = Offset(
      pos.dx - builder.width / 2,
      pos.dy + offsetY,
    );

    // Subtle shadow behind text
    final shadowStyle = TextStyle(
      color: Colors.black.withValues(alpha: 0.6),
      fontSize: 10,
      fontWeight: FontWeight.w500,
      fontFamily: 'monospace',
    );

    final shadowBuilder = TextPainter(
      text: TextSpan(text: text, style: shadowStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    shadowBuilder.paint(canvas, labelPos + const Offset(0.5, 0.5));
    builder.paint(canvas, labelPos);
  }

  @override
  bool shouldRepaint(covariant _StantonMapPainter oldDelegate) {
    return oldDelegate.stars != stars ||
        oldDelegate.orbitScale != orbitScale ||
        oldDelegate.center != center ||
        oldDelegate.planetPositions != planetPositions ||
        oldDelegate.allPositions != allPositions;
  }
}
