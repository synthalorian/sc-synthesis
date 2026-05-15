import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/rust_database_service.dart';
import 'package:sc_synthesis/core/widgets/shimmer_loading.dart';
import 'package:sc_synthesis/core/widgets/fleetyards_link.dart';
import 'package:sc_synthesis/features/ships/ship_detail_screen.dart';
import 'package:sc_synthesis/src/rust/api/model.dart';

/// Ship browser — browse all ships via the embedded Rust/SQLite backend.
/// 100% offline — no server required.
class ShipListScreen extends StatefulWidget {
  final VoidCallback? onTapTheme;

  const ShipListScreen({super.key, this.onTapTheme});

  @override
  State<ShipListScreen> createState() => _ShipListScreenState();
}

class _ShipListScreenState extends State<ShipListScreen> {
  final RustDatabaseService _service = RustDatabaseService();
  List<Ship> _allShips = [];
  List<Ship> _filteredShips = [];
  List<String> _availableSizes = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _sizeFilter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _service.init();
      final ships = await _service.getAllShips();
      final sizes = await _service.getAvailableSizes();
      if (mounted) {
        setState(() {
          _allShips = ships;
          _availableSizes = sizes;
          _loading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _applyFilters() {
    _filteredShips = _allShips.where((s) {
      if (_sizeFilter.isNotEmpty && s.size != _sizeFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!s.name.toLowerCase().contains(q) &&
            !s.manufacturer.toLowerCase().contains(q) &&
            !s.classification.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _formatPrice(double price) =>
      price > 0 ? '\$${price.toInt()}' : '';

  String _cargoLabel(double cargo) =>
      cargo > 0 ? '${cargo.toInt()} SCU' : '';

  String _crewLabel(int min, int max) =>
      max > 1 ? '$min-$max crew' : '1 pilot';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ship Database'),
        centerTitle: true,
        actions: !_loading && _error == null
            ? [
                IconButton(
                  icon: const Icon(Icons.palette_outlined),
                  onPressed: widget.onTapTheme,
                  tooltip: 'Theme',
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showSearch,
                  tooltip: 'Search ships',
                ),
                if (_availableSizes.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter by size',
                    onSelected: (size) {
                      setState(() {
                        _sizeFilter = size;
                        _applyFilters();
                      });
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: '',
                          child: Text('All Sizes'),
                        ),
                        ..._availableSizes.map((size) => PopupMenuItem(
                              value: size,
                              child: Row(
                                children: [
                                  if (_sizeFilter == size)
                                    Icon(Icons.check, size: 18,
                                        color: theme.colorScheme.primary),
                                  if (_sizeFilter == size)
                                    const SizedBox(width: 8),
                                  Text(size),
                                ],
                              ),
                            )),
                      ];
                    },
                  ),
              ]
            : null,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return ShimmerLoading(
        itemCount: 8,
        itemHeight: 92,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Failed to load ship data',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              FleetYardsLink(label: 'Browse ships on FleetYards.net'),
            ],
          ),
        ),
      );
    }

    if (_filteredShips.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 72,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'No ships matching "$_searchQuery"',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _applyFilters();
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear search'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_filteredShips.length} of ${_allShips.length} ships',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_sizeFilter.isNotEmpty) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(_sizeFilter,
                      style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  onDeleted: () {
                    setState(() {
                      _sizeFilter = '';
                      _applyFilters();
                    });
                  },
                ),
              ],
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text('"$_searchQuery"',
                      style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  onDeleted: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                ),
              ],
              const Spacer(),
              FleetYardsLink(compact: true, label: 'FleetYards'),
            ],
          ),
        ),
        // Ship list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _filteredShips.length,
              itemBuilder: (context, index) =>
                  _buildShipCard(theme, _filteredShips[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShipCard(ThemeData theme, Ship ship) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShipDetailScreen(ship: ship),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ship icon with Hero
              Hero(
                tag: 'ship-${ship.id}',
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rocket_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Ship info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Hero(
                            tag: 'ship-name-${ship.id}',
                            child: Text(
                              ship.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (_formatPrice(ship.pledgePrice).isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatPrice(ship.pledgePrice),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ship.manufacturer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _tag(theme, ship.size, _sizeColor(ship.size)),
                        _tag(
                            theme, ship.classification, theme.colorScheme.secondary),
                        _tag(
                            theme,
                            _crewLabel(ship.crewMin, ship.crewMax),
                            theme.colorScheme.tertiary),
                        if (_cargoLabel(ship.cargo).isNotEmpty)
                          _tag(
                              theme, _cargoLabel(ship.cargo), Colors.amber.shade700),
                      ],
                    ),
                  ],
                ),
              ),

              // External link
              InkWell(
                onTap: () => openFleetYards(path: '/ships/${ship.slug}'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSearch() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name, manufacturer, or role...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _searchQuery = '';
                              _applyFilters();
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
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
                onSubmitted: (_) => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              Text(
                '${_filteredShips.length} ships match',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
