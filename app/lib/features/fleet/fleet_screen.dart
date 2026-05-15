import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/api/auth_manager.dart';
import 'package:sc_synthesis/core/api/api_client.dart';
import 'package:sc_synthesis/core/widgets/fleetyards_link.dart';
import 'package:sc_synthesis/core/widgets/shimmer_loading.dart';

/// Fleet screen — shows user's ships from their RSI account
class FleetScreen extends StatefulWidget {
  final AuthManager authManager;

  const FleetScreen({super.key, required this.authManager});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  List<FleetShip> _ships = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.authManager.addListener(_onAuthChanged);
    if (widget.authManager.isAuthenticated) {
      _loadFleet();
    }
  }

  @override
  void dispose() {
    widget.authManager.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
      if (widget.authManager.isAuthenticated) {
        _loadFleet();
      } else {
        _ships = [];
      }
    }
  }

  Future<void> _loadFleet() async {
    setState(() => _loading = true);
    final ships = await ApiClient().getFleet();
    if (mounted) {
      setState(() {
        _ships = ships;
        _loading = false;
      });
    }
  }

  /// Convert a ship name to a FleetYards slug
  String _shipToFleetYardsSlug(FleetShip ship) {
    return ship.name
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s-]"), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = widget.authManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fleet'),
        centerTitle: true,
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _loadFleet,
              tooltip: 'Refresh fleet',
            ),
        ],
      ),
      body: auth.isAuthenticated
          ? _buildFleetContent(theme)
          : _buildSignInPrompt(theme),
    );
  }

  Widget _buildSignInPrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.rocket_launch_outlined,
                size: 44,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Fleet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in with your RSI account to see your ships,\npledges, and fleet value.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () {
                // Switch to profile tab — parent manages tabs
              },
              icon: const Icon(Icons.person),
              label: const Text('Sign in on Profile tab'),
            ),
            const SizedBox(height: 32),
            FleetYardsBanner(
              title: 'FleetYards.net',
              subtitle:
                  'Track your fleet, compare ships, and plan your next pledge.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetContent(ThemeData theme) {
    if (_loading) {
      return ShimmerLoading(
        itemCount: 6,
        itemHeight: 80,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      );
    }

    if (_ships.isEmpty) {
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
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No ships found',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your fleet will appear here after sync.\nPull down to refresh.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: _loadFleet,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(height: 16),
              FleetYardsLink(label: 'Browse all ships on FleetYards'),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFleet,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _ships.length + 1, // +1 for summary header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFleetHeader(theme);
          }
          final ship = _ships[index - 1];
          return _buildShipCard(theme, ship);
        },
      ),
    );
  }

  Widget _buildFleetHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text('Your Fleet', style: theme.textTheme.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_ships.length} ships',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Synced with RSI account',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          FleetYardsLink(
            label: 'Manage your fleet on FleetYards.net',
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShipCard(ThemeData theme, FleetShip ship) {
    final slug = _shipToFleetYardsSlug(ship);

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
                ],
              ),
            ),
            Chip(
              label: Text(
                ship.size,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => openFleetYards(path: '/ships/$slug'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
