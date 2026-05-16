import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/reference_database.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// A location displayed on the starmap.
class _MapLocation {
  final String name;
  final String type;
  final List<String> services;
  final String description;
  final Offset position; // dx = radiusFraction (0-1), dy = angleDeg

  const _MapLocation({
    required this.name,
    required this.type,
    this.services = const [],
    this.description = '',
    required this.position,
  });
}

// ---------------------------------------------------------------------------
// Position derivation — assigns polar (radiusFraction, angleDeg) based on
// location name and type from the JSON reference data.
// ---------------------------------------------------------------------------

Offset _derivePosition(Map<String, dynamic> data) {
  final name = data['name'] as String? ?? '';

  // ---- Planets (precise orbital positions) ----
  if (name == 'Hurston') return const Offset(0.18, 30);
  if (name == 'ArcCorp') return const Offset(0.32, 120);
  if (name == 'Crusader') return const Offset(0.46, 210);
  if (name == 'microTech') return const Offset(0.60, 300);

  // City / landing zones — same position as their parent planet
  if (name == 'Lorville') return const Offset(0.18, 30);
  if (name == 'New Babbage') return const Offset(0.60, 300);
  if (name == 'Area18') return const Offset(0.32, 120);
  if (name == 'Orison') return const Offset(0.46, 210);

  // ---- Stations (offset from parent planet by ±20-30°) ----
  if (name == 'Everus Harbor') return const Offset(0.18, 5);   // Hurston -25°
  if (name == 'Baijini Point') return const Offset(0.34, 140); // ArcCorp +20°
  if (name == 'Seraphim Station') return const Offset(0.48, 180); // Crusader -30°
  if (name == 'Port Tressler') return const Offset(0.62, 325); // microTech +25°

  // ---- Rest stops ----
  if (name == 'R&R HUR (Hurston Orbit)') return const Offset(0.24, 350);
  if (name == 'R&R MIC (microTech Orbit)') return const Offset(0.50, 270);
  if (name == 'R&R ARC (ArcCorp Orbit)') return const Offset(0.39, 105);
  if (name == 'R&R CRU (Crusader Orbit)') return const Offset(0.39, 195);

  // ---- Lagrange points ----
  if (name == 'HUR-L1 Lagrange Station') return const Offset(0.25, 75);
  if (name == 'HUR-L2 Lagrange Station') return const Offset(0.25, 345);
  if (name == 'MIC-L1 Lagrange Station') return const Offset(0.39, 345);
  if (name == 'MIC-L2 Lagrange Station') return const Offset(0.50, 270);
  if (name == 'ARC-L1 Lagrange Station') return const Offset(0.39, 165);
  if (name == 'ARC-L2 Lagrange Station') return const Offset(0.39, 105);
  if (name == 'CRU-L1 Lagrange Station') return const Offset(0.50, 165);
  if (name == 'CRU-L2 Lagrange Station') return const Offset(0.53, 255);
  if (name == 'CRU-L3 Lagrange Station') return const Offset(0.40, 250);

  // Fallback
  return const Offset(0.1, 0);
}

/// Normalise JSON service keys to the display strings expected by
/// [_serviceChip].
String _normaliseService(String raw) {
  switch (raw) {
    case 'landing':
      return 'Ship Spawn';
    case 'cargo':
      return 'Cargo';
    case 'shipShop':
    case 'weaponShop':
    case 'armorShop':
      return 'Shopping';
    case 'medical':
    case 'bar':
      return 'Habitation';
    case 'refining':
      return 'Refueling';
    default:
      return raw;
  }
}

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

/// Map a type string to a colour used for badges and markers.
Color _typeColor(String type) {
  switch (type) {
    case 'planet':
      return const Color(0xFF4FC3F7);
    case 'station':
      return const Color(0xFF8888AA);
    case 'restStop':
      return const Color(0xFFAAAAAA);
    case 'lagrange':
      return const Color(0xFF666688);
    default:
      return const Color(0xFF8888AA);
  }
}

/// Human-readable label for a type string.
String _typeLabel(String type) {
  switch (type) {
    case 'planet':
      return 'Planet';
    case 'station':
      return 'Station';
    case 'restStop':
      return 'Rest Stop';
    case 'lagrange':
      return 'Lagrange Point';
    default:
      return type;
  }
}

/// Icon for a type string.
IconData _typeIcon(String type) {
  switch (type) {
    case 'planet':
      return Icons.public;
    case 'station':
      return Icons.satellite_alt;
    case 'restStop':
      return Icons.local_gas_station;
    case 'lagrange':
      return Icons.trip_origin;
    default:
      return Icons.place;
  }
}

/// Planet name → orbit config lookup, used by the painter for orbit rings
/// and planet-marker colouring.
_OrbitConfig _configForPlanet(String name) {
  switch (name) {
    case 'Hurston':
      return _kOrbitConfigs[0];
    case 'ArcCorp':
      return _kOrbitConfigs[1];
    case 'Crusader':
      return _kOrbitConfigs[2];
    case 'microTech':
      return _kOrbitConfigs[3];
    default:
      return _kOrbitConfigs[0];
  }
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
  final _db = ReferenceDatabase();
  List<_MapLocation> _locations = [];
  bool _loading = true;

  // Cache star positions so they don't flicker on repaint
  List<Offset>? _cachedStars;
  Size? _lastStarSize;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _db.load().then((_) {
      setState(() {
        _locations = _db.locations.map((data) {
          final rawServices =
              (data['services'] as List<dynamic>?)?.cast<String>() ?? [];
          final services = rawServices.map(_normaliseService).toList();
          final pos = _derivePosition(data);
          return _MapLocation(
            name: data['name'] as String? ?? '',
            type: data['type'] as String? ?? '',
            services: services,
            description: data['description'] as String? ?? '',
            position: pos,
          );
        }).toList();
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Stanton System'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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

          final allPositions = <String, Offset>{};
          final typeOfLocation = <String, String>{};

          for (final loc in _locations) {
            final pos = _polarToCartesian(
              center,
              loc.position.dx * orbitScale,
              loc.position.dy,
            );
            allPositions[loc.name] = pos;
            typeOfLocation[loc.name] = loc.type;
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
                  final locName = entry.key;
                  final pos = entry.value;
                  final dist = (tapPos - pos).distance;
                  final type = typeOfLocation[locName] ?? '';
                  final hitRadius = type == 'planet' ? 30.0 : 22.0;
                  if (dist <= hitRadius) {
                    final loc = _locations.firstWhere(
                      (l) => l.name == locName,
                    );
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
                  allPositions: allPositions,
                  typeOfLocation: typeOfLocation,
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
    _MapLocation location,
  ) {
    final typeLabel = _typeLabel(location.type);
    final typeColor = _typeColor(location.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                          _typeIcon(location.type),
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
    required this.allPositions,
    required this.typeOfLocation,
  });

  final List<Offset> stars;
  final double orbitScale;
  final Offset center;
  final Map<String, Offset> allPositions;
  final Map<String, String> typeOfLocation;

  // Pre-generate scan line positions so they stay stable across repaints
  static final List<double> _scanLines = List.generate(12, (i) {
    return 0.04 + (i * 0.085);
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawnLabelBounds.clear();
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
    for (final entry in allPositions.entries) {
      final name = entry.key;
      final pos = entry.value;
      final type = typeOfLocation[name] ?? '';

      switch (type) {
        case 'planet':
          final config = _configForPlanet(name);
          _drawPlanetMarker(canvas, pos, config, name);
          break;
        case 'station':
          _drawStationMarker(canvas, pos, name);
          break;
        case 'restStop':
          _drawRestStopMarker(canvas, pos, name);
          break;
        case 'lagrange':
          _drawLagrangeMarker(canvas, pos, name);
          break;
      }
    }
  }

  // -----------------------------------------------------------------------
  // Individual marker types
  // -----------------------------------------------------------------------
  void _drawPlanetMarker(Canvas canvas, Offset pos, _OrbitConfig config, String name) {
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
    _drawLabel(canvas, pos, name,
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
  // Label drawing with collision detection
  // -----------------------------------------------------------------------

  final List<Rect> _drawnLabelBounds = [];

  void _drawLabel(
    Canvas canvas,
    Offset pos,
    String text,
    Color color,
    double offsetY,
  ) {
    const double fontSize = 10;
    const double padding = 3;

    final textStyle = TextStyle(
      color: color.withValues(alpha: 0.85),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontFamily: 'monospace',
    );

    final builder = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final textW = builder.width;
    const textH = fontSize + 4;

    // Try label positions in order of preference until one doesn't overlap
    final anchors = <Offset>[
      // 1. Below center (default)
      Offset(pos.dx - textW / 2, pos.dy + offsetY),
      // 2. Above center
      Offset(pos.dx - textW / 2, pos.dy - offsetY - textH),
      // 3. Right
      Offset(pos.dx + offsetY, pos.dy - textH / 2),
      // 4. Left
      Offset(pos.dx - offsetY - textW, pos.dy - textH / 2),
      // 5. Above-right
      Offset(pos.dx + offsetY * 0.5, pos.dy - offsetY - textH),
      // 6. Above-left
      Offset(pos.dx - offsetY * 0.5 - textW, pos.dy - offsetY - textH),
    ];

    Offset? chosenPos;
    for (final anchor in anchors) {
      final labelRect = Rect.fromLTWH(
        anchor.dx - padding,
        anchor.dy - padding,
        textW + padding * 2,
        textH + padding * 2,
      );
      final overlaps = _drawnLabelBounds.any((r) => r.overlaps(labelRect));
      if (!overlaps) {
        chosenPos = anchor;
        break;
      }
    }

    // Fallback: use default position even if overlapping
    chosenPos ??= anchors.first;

    final labelRect = Rect.fromLTWH(
      chosenPos.dx - padding,
      chosenPos.dy - padding,
      textW + padding * 2,
      textH + padding * 2,
    );
    _drawnLabelBounds.add(labelRect);

    // Subtle shadow behind text
    final shadowStyle = TextStyle(
      color: Colors.black.withValues(alpha: 0.6),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontFamily: 'monospace',
    );

    final shadowBuilder = TextPainter(
      text: TextSpan(text: text, style: shadowStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    shadowBuilder.paint(canvas, chosenPos + const Offset(0.5, 0.5));
    builder.paint(canvas, chosenPos);
  }

  @override
  bool shouldRepaint(covariant _StantonMapPainter oldDelegate) {
    return oldDelegate.stars != stars ||
        oldDelegate.orbitScale != orbitScale ||
        oldDelegate.center != center ||
        oldDelegate.allPositions != allPositions ||
        oldDelegate.typeOfLocation != typeOfLocation;
  }
}
