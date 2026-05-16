import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/rust_database_service.dart';
import 'package:sc_synthesis/core/widgets/fleetyards_link.dart';
import 'package:sc_synthesis/core/widgets/ship_image.dart';
import 'package:sc_synthesis/src/rust/api/model.dart';

/// Ship Comparison screen — compare up to 3 ships side by side.
///
/// Features:
///  - searchable bottom sheet to add ships from the local database
///  - horizontal scrollable comparison cards with glassmorphism styling
///  - relative stat bars for numeric values (cargo, speed, price, crew)
///  - color-coded size badges, FleetYards links, and per-card remove buttons
class ShipCompareScreen extends StatefulWidget {
  const ShipCompareScreen({super.key});

  @override
  State<ShipCompareScreen> createState() => _ShipCompareScreenState();
}

class _ShipCompareScreenState extends State<ShipCompareScreen> {
  final RustDatabaseService _service = RustDatabaseService();
  final Set<Ship> _selectedShips = {};
  static const int _maxShips = 3;

  ui.ImageFilter _glassBlur() => ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);

  Color _sizeColor(String size) {
    switch (size.toLowerCase()) {
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

  String _crewLabel(int min, int max) => max > 1 ? '$min-$max crew' : '1 pilot';

  String _cargoLabel(double cargo) => cargo > 0 ? '${cargo.toInt()} SCU' : '';

  String _speedLabel(double speed) =>
      speed > 0 ? '${speed.toInt()} m/s' : '';

  String _formatPrice(double price) =>
      price > 0 ? '\$${price.toInt()}' : '';

  // ── Add Ship Bottom Sheet ──────────────────────────────────────────

  void _showAddShipSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AddShipSheet(
        service: _service,
        selectedShips: _selectedShips,
        onShipSelected: (ship) {
          setState(() => _selectedShips.add(ship));
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ship Comparison'),
        centerTitle: true,
        actions: [
          if (_selectedShips.length < _maxShips)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showAddShipSheet,
              tooltip: 'Add Ship',
            ),
          if (_selectedShips.length >= 2)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => setState(_selectedShips.clear),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: _selectedShips.isEmpty
          ? _buildEmptyState(theme, cs)
          : _buildComparison(theme, cs),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 72,
              color: cs.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 20),
            Text(
              'Ship Comparison',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select ships to compare.\nAdd your first ship to get started.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: _showAddShipSheet,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Ship'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(ThemeData theme, ColorScheme cs) {
    // Compute max values for relative stat bars
    double maxCargo = 0, maxSpeed = 0, maxPrice = 0, maxCrew = 0;
    for (final ship in _selectedShips) {
      if (ship.cargo > maxCargo) maxCargo = ship.cargo;
      if (ship.maxSpeed > maxSpeed) maxSpeed = ship.maxSpeed;
      if (ship.pledgePrice > maxPrice) maxPrice = ship.pledgePrice;
      if (ship.crewMax > maxCrew) maxCrew = ship.crewMax.toDouble();
    }

    return Column(
      children: [
        // Info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: cs.onSurface.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.compare_arrows, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                '${_selectedShips.length} ship${_selectedShips.length != 1 ? 's' : ''} selected',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_selectedShips.length < _maxShips)
                TextButton.icon(
                  onPressed: _showAddShipSheet,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: cs.primary,
                  ),
                ),
            ],
          ),
        ),
        // Horizontal scrollable comparison cards
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _selectedShips
                  .map((ship) => _buildShipCompareCard(
                        theme,
                        cs,
                        ship,
                        maxCargo,
                        maxSpeed,
                        maxPrice,
                        maxCrew,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShipCompareCard(
    ThemeData theme,
    ColorScheme cs,
    Ship ship,
    double maxCargo,
    double maxSpeed,
    double maxPrice,
    double maxCrew,
  ) {
    final sizeColor = _sizeColor(ship.size);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
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
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: _glassBlur(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon, name, FleetYards link, Remove
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    ShipAvatar(manufacturer: ship.manufacturer, slug: ship.slug, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ship.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // FleetYards link
                    InkWell(
                      onTap: () =>
                          openFleetYards(path: '/ships/${ship.slug}'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: cs.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Remove button
                    InkWell(
                      onTap: () =>
                          setState(() => _selectedShips.remove(ship)),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: cs.error.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Manufacturer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ship.manufacturer,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.secondary,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A50), height: 1),
              const SizedBox(height: 8),
              // Scrollable stats list
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      _compareStat(
                        theme,
                        cs,
                        'Pledge Price',
                        _formatPrice(ship.pledgePrice),
                        ship.pledgePrice,
                        maxPrice,
                        cs.primary,
                      ),
                      const SizedBox(height: 8),
                      _compareStat(
                        theme,
                        cs,
                        'Size',
                        ship.size,
                        0,
                        0,
                        sizeColor,
                        badge: ship.size,
                        badgeColor: sizeColor,
                      ),
                      const SizedBox(height: 8),
                      _compareStat(
                        theme,
                        cs,
                        'Classification',
                        ship.classification,
                        0,
                        0,
                        cs.secondary,
                      ),
                      const SizedBox(height: 8),
                      _compareStat(
                        theme,
                        cs,
                        'Crew',
                        _crewLabel(ship.crewMin, ship.crewMax),
                        ship.crewMax.toDouble(),
                        maxCrew,
                        Colors.amber.shade600,
                      ),
                      const SizedBox(height: 8),
                      _compareStat(
                        theme,
                        cs,
                        'Cargo',
                        _cargoLabel(ship.cargo),
                        ship.cargo,
                        maxCargo,
                        Colors.amber.shade700,
                      ),
                      const SizedBox(height: 8),
                      _compareStat(
                        theme,
                        cs,
                        'Max Speed',
                        _speedLabel(ship.maxSpeed),
                        ship.maxSpeed,
                        maxSpeed,
                        cs.error,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compareStat(
    ThemeData theme,
    ColorScheme cs,
    String label,
    String value,
    double current,
    double max,
    Color color, {
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.04),
        border: Border.all(
          color: color.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor?.withValues(alpha: 0.15) ??
                        color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: badgeColor ?? color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          if (max > 0) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / max,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.7)),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Add Ship Searchable Bottom Sheet ──────────────────────────────────

class _AddShipSheet extends StatefulWidget {
  final RustDatabaseService service;
  final Set<Ship> selectedShips;
  final ValueChanged<Ship> onShipSelected;

  const _AddShipSheet({
    required this.service,
    required this.selectedShips,
    required this.onShipSelected,
  });

  @override
  State<_AddShipSheet> createState() => _AddShipSheetState();
}

class _AddShipSheetState extends State<_AddShipSheet> {
  List<Ship> _allShips = [];
  List<Ship> _filteredShips = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await widget.service.init();
      final ships = await widget.service.getAllShips();
      if (mounted) {
        setState(() {
          _allShips = ships;
          _loading = false;
          _applyFilter();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredShips = _allShips.where((s) {
        if (widget.selectedShips.contains(s)) return false;
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase();
          if (!s.name.toLowerCase().contains(q) &&
              !s.manufacturer.toLowerCase().contains(q) &&
              !s.classification.toLowerCase().contains(q)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add Ship to Compare',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_filteredShips.length} available',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search ships...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _query = '';
                          _applyFilter();
                        });
                      },
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _query = value;
              _applyFilter();
            },
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredShips.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                _query.isNotEmpty
                    ? 'No ships match "$_query"'
                    : 'All ships already added',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.separated(
                itemCount: _filteredShips.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ship = _filteredShips[index];
                  return ListTile(
                    leading: ShipAvatar(
                      manufacturer: ship.manufacturer,
                      slug: ship.slug,
                      size: 36,
                    ),
                    title: Text(
                      ship.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${ship.manufacturer} · ${ship.classification}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    trailing: Icon(Icons.add_circle_outline,
                        color: cs.primary, size: 20),
                    onTap: () => widget.onShipSelected(ship),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
