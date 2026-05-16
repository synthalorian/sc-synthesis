import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/reference_database.dart';
import 'package:sc_synthesis/features/guide/guide_category_screen.dart';

/// A category entry for the guide hub.
class _GuideCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String dbCategory;

  const _GuideCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.dbCategory,
  });
}

/// Guide hub screen — the central reference index for Star Citizen lore,
/// factions, missions, locations, and commodities.
///
/// Each category card navigates to a [GuideCategoryScreen] filtered to
/// that category's data from the [ReferenceDatabase].
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final ReferenceDatabase _db = ReferenceDatabase();
  bool _loading = true;
  String? _error;

  static const List<_GuideCategory> _categories = [
    _GuideCategory(
      id: 'factions',
      title: 'Factions & Reputation',
      subtitle: 'Organizations, rep tiers, and affiliations',
      icon: Icons.groups,
      iconColor: Color(0xFFFF00FF),
      dbCategory: 'factions',
    ),
    _GuideCategory(
      id: 'missions',
      title: 'Contracts & Missions',
      subtitle: 'Bounty, mercenary, delivery, and more',
      icon: Icons.assignment,
      iconColor: Color(0xFF00D4FF),
      dbCategory: 'missions',
    ),
    _GuideCategory(
      id: 'locations',
      title: 'Locations',
      subtitle: 'Planets, stations, points of interest',
      icon: Icons.public,
      iconColor: Color(0xFF00FF41),
      dbCategory: 'locations',
    ),
    _GuideCategory(
      id: 'commodities',
      title: 'Commodities',
      subtitle: 'Trade goods, prices, and legality',
      icon: Icons.inventory_2,
      iconColor: Color(0xFFFF8C00),
      dbCategory: 'commodities',
    ),
    _GuideCategory(
      id: 'mining',
      title: 'Mining & Salvage',
      subtitle: 'Resources, gadgets, and extraction',
      icon: Icons.explore,
      iconColor: Color(0xFFB57EDC),
      dbCategory: 'commodities',
    ),
    _GuideCategory(
      id: 'components',
      title: 'Components',
      subtitle: 'Shields, weapons, power plants, coolers',
      icon: Icons.build,
      iconColor: Color(0xFFFF5555),
      dbCategory: 'commodities',
    ),
    _GuideCategory(
      id: 'medical',
      title: 'Medical & Survival',
      subtitle: 'Healing, respawn, and life support',
      icon: Icons.medical_services,
      iconColor: Color(0xFF55FF55),
      dbCategory: 'commodities',
    ),
    _GuideCategory(
      id: 'org-roster',
      title: 'Org Roster',
      subtitle: 'Organization members and contacts',
      icon: Icons.people,
      iconColor: Color(0xFFFFD700),
      dbCategory: 'factions',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _db.load();
      if (mounted) {
        setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Guide'),
        centerTitle: true,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
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
                'Failed to load reference data',
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
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _load();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) =>
              _buildCategoryCard(theme, _categories[index]),
        );
      },
    );
  }

  Widget _buildCategoryCard(ThemeData theme, _GuideCategory category) {
    final neonColor = category.iconColor;
    final surfaceColor = theme.colorScheme.surface;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: neonColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      elevation: 6,
      shadowColor: neonColor.withValues(alpha: 0.25),
      color: surfaceColor.withValues(alpha: 0.85),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openCategory(context, category),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                surfaceColor.withValues(alpha: 0.6),
                surfaceColor,
                surfaceColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon in a colored circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: neonColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: neonColor.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    color: neonColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Title
                Text(
                  category.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  category.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Chevron
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: neonColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: neonColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, _GuideCategory category) {
    List<Map<String, dynamic>> data;
    switch (category.dbCategory) {
      case 'factions':
        data = _db.factions;
        break;
      case 'missions':
        data = _db.missions;
        break;
      case 'locations':
        data = _db.locations;
        break;
      case 'commodities':
        data = _db.commodities;
        break;
      default:
        data = _db.factions;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuideCategoryScreen(
          categoryId: category.id,
          categoryTitle: category.title,
          categoryIcon: category.icon,
          categoryIconColor: category.iconColor,
          items: data,
        ),
      ),
    );
  }
}
