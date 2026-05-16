import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/rust_database_service.dart';
import 'package:sc_synthesis/core/data/user_ship_data.dart';
import 'package:sc_synthesis/core/widgets/shimmer_loading.dart';
import 'package:sc_synthesis/src/rust/api/model.dart';

/// Offline-local fleet manager.
/// Loads ships from the bundled SQLite database via RustDatabaseService,
/// overlays UserShipData for owned/wishlist tracking.
class FleetScreen extends StatefulWidget {
  final VoidCallback? onSwitchToShipsTab;

  const FleetScreen({super.key, this.onSwitchToShipsTab});

  @override
  State<FleetScreen> createState() => FleetScreenState();
}

class FleetScreenState extends State<FleetScreen>
    with SingleTickerProviderStateMixin {
  final _rustDb = RustDatabaseService();
  final _userData = UserShipData();

  late TabController _tabController;

  List<Ship> _allShips = [];
  List<Ship> _ownedShips = [];
  List<Ship> _wishlistShips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userData.addListener(_onUserDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    _userData.removeListener(_onUserDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onUserDataChanged() {
    if (mounted) {
      _reindexShips();
    }
  }

  /// Filter all ships into owned and wishlist sets based on UserShipData.
  void _reindexShips() {
    final ownedIds = _userData.ownedIds;
    final wishlistIds = _userData.wishlistIds;
    setState(() {
      _ownedShips =
          _allShips.where((s) => ownedIds.contains(s.id)).toList();
      _wishlistShips =
          _allShips.where((s) => wishlistIds.contains(s.id)).toList();
    });
  }

  Future<void> _loadData() async {
    if (!_rustDb.isInitialized) {
      try {
        await _rustDb.init();
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Failed to initialize database: $e';
            _loading = false;
          });
        }
        return;
      }
    }

    await _userData.load();

    try {
      final ships = await _rustDb.getAllShips();
      if (mounted) {
        setState(() {
          _allShips = ships;
          _loading = false;
        });
        _reindexShips();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load ships: $e';
          _loading = false;
        });
      }
    }
  }

  /// Compute total fleet value (sum of pledge prices for owned ships).
  double get _fleetValue {
    double total = 0;
    for (final ship in _ownedShips) {
      total += ship.pledgePrice;
    }
    return total;
  }

  /// Unique manufacturers among owned ships.
  Set<String> get _ownedManufacturers {
    return _ownedShips.map((s) => s.manufacturer).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fleet'),
        centerTitle: true,
        bottom: _loading
            ? null
            : TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'My Fleet (${_ownedShips.length})'),
                  Tab(text: 'Wishlist (${_wishlistShips.length})'),
                ],
              ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return ShimmerLoading(
        itemCount: 6,
        itemHeight: 80,
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
              Icon(Icons.error_outline, size: 48,
                  color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () {
                  setState(() => _loading = true);
                  _error = null;
                  _loadData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Stats summary bar
        _buildStatsBar(theme),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFleetTab(theme, isWishlist: false),
              _buildFleetTab(theme, isWishlist: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          _statChip(theme, Icons.rocket_launch_outlined,
              '${_ownedShips.length} owned'),
          const SizedBox(width: 12),
          _statChip(theme, Icons.favorite_outline,
              '${_wishlistShips.length} wanted'),
          const SizedBox(width: 12),
          _statChip(theme, Icons.business,
              '${_ownedManufacturers.length} manufacturers'),
          const Spacer(),
          if (_fleetValue > 0)
            Text(
              'US\$${_fleetValue.toStringAsFixed(0)}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statChip(ThemeData theme, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFleetTab(ThemeData theme, {required bool isWishlist}) {
    final ships = isWishlist ? _wishlistShips : _ownedShips;

    if (ships.isEmpty) {
      return _buildEmptyState(theme, isWishlist: isWishlist);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: ships.length,
        itemBuilder: (context, index) {
          final ship = ships[index];
          return _buildShipCard(theme, ship, isWishlist: isWishlist);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, {required bool isWishlist}) {
    final icon = isWishlist ? Icons.favorite_outline : Icons.rocket_launch_outlined;
    final title = isWishlist ? 'Wishlist is empty' : 'No ships in your fleet yet';
    final subtitle = isWishlist
        ? 'Browse the Ships tab and add ships to your wishlist.\nTap the heart icon on any ship to save it here.'
        : 'Head to the Ships tab to find ships and add them\nto your fleet with the "Own" toggle.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: widget.onSwitchToShipsTab,
              icon: const Icon(Icons.search),
              label: const Text('Browse Ships'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipCard(ThemeData theme, Ship ship,
      {required bool isWishlist}) {
    final note = _userData.getNote(ship.id);
    final priceLabel = ship.pledgePrice > 0
        ? 'US\$ ${ship.pledgePrice.toStringAsFixed(0)}'
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Ship icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.rocket_outlined,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Name + manufacturer + optional note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ship.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ship.manufacturer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Price tag (if available)
            if (priceLabel.isNotEmpty && !isWishlist) ...[
              Text(
                priceLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Remove button
            IconButton(
              onPressed: () {
                if (isWishlist) {
                  _userData.toggleWishlist(ship.id);
                } else {
                  _userData.toggleOwned(ship.id);
                }
              },
              icon: Icon(
                isWishlist ? Icons.delete_outline : Icons.remove_circle_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              tooltip: isWishlist ? 'Remove from wishlist' : 'Remove from fleet',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
