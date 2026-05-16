import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/reference_database.dart';

/// Mining & Salvage Guide screen.
///
/// A two-tab guide displaying mining gadgets/modules/consumables/resources
/// and salvage modules/consumables/resources from the [ReferenceDatabase]
/// singleton. Uses a synthwave glassmorphism card style with neon accents:
/// green for mining, orange for salvage.
class MiningSalvageScreen extends StatefulWidget {
  const MiningSalvageScreen({super.key});

  @override
  State<MiningSalvageScreen> createState() => _MiningSalvageScreenState();
}

class _MiningSalvageScreenState extends State<MiningSalvageScreen>
    with SingleTickerProviderStateMixin {
  final ReferenceDatabase _db = ReferenceDatabase();
  late final TabController _tabController;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Mining & Salvage'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, size: 18),
                  SizedBox(width: 8),
                  Text('Mining'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.recycling, size: 18),
                  SizedBox(width: 8),
                  Text('Salvage'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildMiningTab(theme),
        _buildSalvageTab(theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mining Tab
  // ---------------------------------------------------------------------------

  Widget _buildMiningTab(ThemeData theme) {
    final items = _db.miningGadgets;

    final lasers =
        items.where((i) => i['type'] == 'gadget' && _hasSubtype(i, 'Laser')).toList();
    final modules =
        items.where((i) => i['type'] == 'module').toList();
    final consumables =
        items.where((i) => i['type'] == 'consumable').toList();
    final resources =
        items.where((i) => i['type'] == 'resource').toList()
          ..sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));

    return _buildTabContent(
      theme: theme,
      accentColor: const Color(0xFF00FF41), // neon green
      sections: [
        _SectionData('Mining Lasers', Icons.explore, lasers, true),
        _SectionData('Mining Modules', Icons.build_circle, modules, true),
        _SectionData('Consumables', Icons.science, consumables, false),
        _SectionData('Valuable Resources', Icons.diamond, resources, false),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Salvage Tab
  // ---------------------------------------------------------------------------

  Widget _buildSalvageTab(ThemeData theme) {
    final items = _db.salvageData;

    final heads = items.where((i) => i['type'] == 'module').toList();
    final consumables =
        items.where((i) => i['type'] == 'consumable').toList();
    final resources =
        items.where((i) => i['type'] == 'resource').toList()
          ..sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));

    return _buildTabContent(
      theme: theme,
      accentColor: const Color(0xFFFF8C00), // neon orange
      sections: [
        _SectionData('Salvage Heads', Icons.camera_outdoor, heads, true),
        _SectionData('Salvage Consumables', Icons.science, consumables, false),
        _SectionData('Salvage Resources', Icons.inventory_2, resources, false),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared tab content builder
  // ---------------------------------------------------------------------------

  Widget _buildTabContent({
    required ThemeData theme,
    required Color accentColor,
    required List<_SectionData> sections,
  }) {
    // Filter out empty sections
    final nonEmpty = sections.where((s) => s.items.isNotEmpty).toList();

    if (nonEmpty.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 36,
                  color: accentColor.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No data available',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Mining & Salvage data will appear here\nonce available.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: nonEmpty.length,
      itemBuilder: (context, index) {
        final section = nonEmpty[index];
        return _buildSection(theme, accentColor, section);
      },
    );
  }

  Widget _buildSection(
    ThemeData theme,
    Color accentColor,
    _SectionData section,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              Icon(section.icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${section.items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Section items
        ...section.items.map(
          (item) => _buildItemCard(theme, accentColor, item, section.showTier),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Item card
  // ---------------------------------------------------------------------------

  Widget _buildItemCard(
    ThemeData theme,
    Color accentColor,
    Map<String, dynamic> item,
    bool showTier,
  ) {
    final name = item['name'] as String? ?? 'Unknown';
    final description = item['description'] as String? ?? '';
    final effect = item['effect'] as String? ?? '';
    final type = item['type'] as String? ?? '';
    final subtype = item['subtype'] as String? ?? '';
    final price = item['price'] as num? ?? 0;
    final tier = item['tier'] as int?;

    final typeBadge = _formatType(type, subtype);
    final typeColor = _typeColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      elevation: 3,
      shadowColor: accentColor.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.7),
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Name + price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Type badge
                            if (typeBadge.isNotEmpty)
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
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  typeBadge,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: typeColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            // Tier indicator
                            if (showTier && tier != null) ...[
                              const SizedBox(width: 8),
                              _buildTierIndicator(theme, accentColor, tier),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPrice(price),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.monetization_on_outlined,
                          size: 12,
                          color: accentColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
              ],

              // Effect (italic)
              if (effect.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  effect,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: accentColor.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tier indicator
  // ---------------------------------------------------------------------------

  Widget _buildTierIndicator(
    ThemeData theme,
    Color accentColor,
    int tier,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < tier;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            size: 14,
            color: filled ? accentColor : accentColor.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _hasSubtype(Map<String, dynamic> item, String value) {
    final subtype = item['subtype'] as String? ?? '';
    return subtype.toLowerCase().contains(value.toLowerCase());
  }

  String _formatType(String type, String subtype) {
    if (type == 'gadget') return 'Laser';
    if (type == 'module') return 'Module';
    if (type == 'consumable') return 'Consumable';
    if (type == 'resource') return 'Resource';
    return type;
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'gadget':
        return const Color(0xFF00D4FF); // cyan
      case 'module':
        return const Color(0xFFFF00FF); // magenta
      case 'consumable':
        return const Color(0xFFFFD700); // gold
      case 'resource':
        return const Color(0xFF55FF55); // green
      default:
        return const Color(0xFF8888AA);
    }
  }

  String _formatPrice(num price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    } else if (price == price.truncateToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }
}

/// Internal data holder for a section of items within a tab.
class _SectionData {
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final bool showTier;

  const _SectionData(this.title, this.icon, this.items, this.showTier);
}
