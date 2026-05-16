import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/user_ship_data.dart';
import 'package:sc_synthesis/src/rust/api/model.dart';
import 'package:sc_synthesis/core/widgets/ship_image.dart';
import 'package:sc_synthesis/core/widgets/fleetyards_link.dart';

/// Full-screen ship detail view with synthwave '84 aesthetic.
/// Glassmorphism cards, neon gradients, and premium layout.
/// Includes offline-owned/wishlist toggles and personal notes.
class ShipDetailScreen extends StatefulWidget {
  final Ship ship;

  const ShipDetailScreen({super.key, required this.ship});

  @override
  State<ShipDetailScreen> createState() => _ShipDetailScreenState();
}

class _ShipDetailScreenState extends State<ShipDetailScreen> {
  final _userData = UserShipData();
  late TextEditingController _notesController;
  bool _isOwned = false;
  bool _isWishlisted = false;

  Ship get ship => widget.ship;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: _userData.getNote(ship.id) ?? '');
    _isOwned = _userData.isOwned(ship.id);
    _isWishlisted = _userData.isWishlisted(ship.id);
    _userData.addListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    _userData.removeListener(_onUserDataChanged);
    _notesController.dispose();
    super.dispose();
  }

  void _onUserDataChanged() {
    if (mounted) {
      setState(() {
        _isOwned = _userData.isOwned(ship.id);
        _isWishlisted = _userData.isWishlisted(ship.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, cs),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildHeroSection(context, theme, cs),
                const SizedBox(height: 16),
                _buildOwnedToggle(theme, cs),
                const SizedBox(height: 12),
                _buildStatsGrid(theme, cs),
                const SizedBox(height: 16),
                _buildDescriptionSection(theme, cs),
                const SizedBox(height: 16),
                _buildNotesSection(theme, cs),
                const SizedBox(height: 16),
                _buildFleetYardsBanner(theme, cs),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Owned/Wishlist Toggle Section ─────────────────────────────────────

  Widget _buildOwnedToggle(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E0E24),
            const Color(0xFF16163A).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: _glassBlur(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_outline,
                          size: 16, color: cs.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'YOUR FLEET',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.secondary.withValues(alpha: 0.8),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF2A2A50), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _toggleButton(
                        theme: theme,
                        cs: cs,
                        icon: Icons.rocket_launch,
                        label: 'Own this ship',
                        active: _isOwned,
                        activeColor: cs.primary,
                        onTap: () => _userData.toggleOwned(ship.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _toggleButton(
                        theme: theme,
                        cs: cs,
                        icon: Icons.favorite,
                        label: 'Wishlist',
                        active: _isWishlisted,
                        activeColor: Colors.pinkAccent,
                        onTap: () => _userData.toggleWishlist(ship.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isOwned
                      ? 'Added to your fleet'
                      : _isWishlisted
                          ? 'On your wishlist'
                          : 'Tap a button above to track this ship',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton({
    required ThemeData theme,
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: active
              ? activeColor.withValues(alpha: 0.15)
              : cs.onSurface.withValues(alpha: 0.04),
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.4)
                : cs.onSurface.withValues(alpha: 0.08),
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              active ? icon : Icons.add_circle_outline,
              color: active ? activeColor : cs.onSurface.withValues(alpha: 0.5),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: active
                    ? activeColor
                    : cs.onSurface.withValues(alpha: 0.6),
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Notes Section ───────────────────────────────────────────────────────

  Widget _buildNotesSection(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E0E24),
            const Color(0xFF16163A).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: _glassBlur(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 16, color: cs.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'PERSONAL NOTES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.secondary.withValues(alpha: 0.8),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF2A2A50), height: 20),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  minLines: 2,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note about this ship...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: cs.onSurface.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: cs.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: cs.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: cs.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (value) {
                    _userData.setNote(ship.id, value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sliver AppBar ──────────────────────────────────────────────────────

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: cs.secondary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(bottom: 20, left: 16, right: 64),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ship-${ship.id}',
              child: ShipAvatar(manufacturer: ship.manufacturer, size: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Hero(
                tag: 'ship-name-${ship.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    ship.name,
                    style: TextStyle(
                      color: cs.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.scaffoldBackgroundColor,
                const Color(0xFF0E0E24),
                cs.primary.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative grid pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPainter(theme: theme),
                ),
              ),
              // Neon glow dots
              Positioned(
                top: 40,
                right: 40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.12),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.secondary.withValues(alpha: 0.08),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.open_in_new, color: cs.primary),
          tooltip: 'View on FleetYards',
          onPressed: () => openFleetYards(path: '/ships/${ship.slug}'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Hero Section ───────────────────────────────────────────────────────

  Widget _buildHeroSection(
      BuildContext context, ThemeData theme, ColorScheme cs) {
    final priceLabel = ship.pledgePrice > 0
        ? 'US\$ ${ship.pledgePrice.toStringAsFixed(0)}'
        : '';
    return ShipHero(
      name: ship.name,
      manufacturer: ship.manufacturer,
      priceLabel: priceLabel,
    );
  }

  // ── Stats Grid ─────────────────────────────────────────────────────────

  Widget _buildStatsGrid(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E0E24),
            const Color(0xFF16163A).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: _glassBlur(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.grid_on, size: 16, color: cs.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'STATISTICS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.secondary.withValues(alpha: 0.8),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF2A2A50), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _statTile(
                            theme, cs, 'Size', ship.size, _sizeColor(cs))),
                    Expanded(
                        child: _statTile(theme, cs, 'Class',
                            ship.classification, cs.secondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _statTile(
                            theme, cs, 'Focus', ship.focus, cs.tertiary)),
                    Expanded(
                        child: _statTile(
                            theme,
                            cs,
                            'Crew',
                            _crewLabel(ship.crewMin, ship.crewMax),
                            Colors.amber.shade600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _statTile(theme, cs, 'Cargo',
                            _cargoLabel(ship.cargo), Colors.amber.shade700)),
                    Expanded(
                        child: _statTile(theme, cs, 'Max Speed',
                            _speedLabel(ship.maxSpeed), cs.error)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statTile(
      ThemeData theme, ColorScheme cs, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.06),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: 1.5,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Description Section ────────────────────────────────────────────────

  Widget _buildDescriptionSection(ThemeData theme, ColorScheme cs) {
    if (ship.description.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E0E24),
            const Color(0xFF16163A).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: _glassBlur(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 16, color: cs.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'DESCRIPTION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.secondary.withValues(alpha: 0.8),
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF2A2A50), height: 20),
                Text(
                  ship.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── FleetYards Banner ──────────────────────────────────────────────────

  Widget _buildFleetYardsBanner(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.08),
            cs.secondary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.open_in_new,
                color: cs.primary,
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
                    ship.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View on FleetYards.net for full specs and compare tools.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FleetYardsLink(
                    path: '/ships/${ship.slug}',
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Color _sizeColor(ColorScheme cs) {
    switch (ship.size.toLowerCase()) {
      case 'snub':
        return Colors.grey;
      case 'small':
        return Colors.lightGreen;
      case 'medium':
        return Colors.orange;
      case 'large':
        return Colors.deepOrange;
      case 'capital':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _crewLabel(int min, int max) =>
      max > 1 ? '$min-$max crew' : '1 pilot';

  String _cargoLabel(double cargo) => cargo > 0 ? '${cargo.toInt()} SCU' : '-';

  String _speedLabel(double speed) => speed > 0 ? '${speed.toInt()} m/s' : '-';
}

// ── Grid Painter ─────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final ThemeData theme;

  _GridPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Glass Blur ───────────────────────────────────────────────────────────

ui.ImageFilter _glassBlur() {
  return ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);
}
