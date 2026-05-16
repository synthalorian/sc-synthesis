import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/widgets/component_image.dart';

/// Generic category detail screen for the Guide hub.
///
/// Receives a category's items from [ReferenceDatabase] and displays them
/// in a styled list with glassmorphism cards matching the app's synthwave
/// design language.
class GuideCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;
  final IconData categoryIcon;
  final Color categoryIconColor;
  final List<Map<String, dynamic>> items;

  const GuideCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.categoryIconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(categoryIcon, size: 22, color: categoryIconColor),
            const SizedBox(width: 10),
            Text(categoryTitle),
          ],
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
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
                        color: categoryIconColor.withValues(alpha: 0.08),
                        border: Border.all(
                          color: categoryIconColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Icon(
                        categoryIcon,
                        size: 36,
                        color: categoryIconColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nothing here yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data for $categoryTitle will appear here\nonce available.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _buildItemCard(context, theme, items[index]),
            ),
    );
  }

  Widget _buildItemCard(
      BuildContext context, ThemeData theme, Map<String, dynamic> item) {
    final name = item['name'] as String? ?? 'Unknown';
    final description = item['description'] as String? ?? '';
    final typeLabel = _resolveTypeLabel(item);
    final typeColor = _resolveTypeColor(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: categoryIconColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      elevation: 3,
      shadowColor: categoryIconColor.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDetail(context, item),
        borderRadius: BorderRadius.circular(14),
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
                // Title row with badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon for the item
                    if (categoryId == 'components')
                      ComponentAvatar(
                        category: item['category'] as String? ?? '',
                        manufacturer: item['manufacturer'] as String? ?? '',
                        size: 40,
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: categoryIconColor.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          categoryIcon,
                          size: 20,
                          color: categoryIconColor,
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Name and badge
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
                          if (typeLabel.isNotEmpty) ...[
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
                                  width: 0.5,
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
                        ],
                      ),
                    ),
                  ],
                ),
                // Description preview
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ],
                // Extra detail row based on category
                if (_hasExtraDetail(item)) ...[
                  const SizedBox(height: 10),
                  _buildExtraDetailRow(theme, item),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a detail bottom sheet for the tapped item.
  void _showItemDetail(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final name = item['name'] as String? ?? 'Unknown';
    final typeLabel = _resolveTypeLabel(item);
    final typeColor = _resolveTypeColor(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

                  // Header: icon + name + type badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: categoryIconColor.withValues(alpha: 0.12),
                          border: Border.all(
                            color: categoryIconColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: categoryIconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (typeLabel.isNotEmpty)
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

                  // Category-specific content
                  ..._buildDetailContent(ctx, theme, item),

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

  /// Builds the body content based on categoryId.
  List<Widget> _buildDetailContent(
      BuildContext context, ThemeData theme, Map<String, dynamic> item) {
    final description = item['description'] as String? ?? '';
    final typeLabel = _resolveTypeLabel(item);
    final typeColor = _resolveTypeColor(item);

    switch (categoryId) {
      case 'factions':
        return _buildFactionDetail(theme, item, description);
      case 'missions':
        return _buildMissionDetail(theme, item, description);
      case 'commodities':
        return _buildCommodityDetail(theme, item, description, typeLabel, typeColor);
      case 'locations':
        return _buildLocationDetail(theme, item, description);
      default:
        return _buildDefaultDetail(theme, item, description);
    }
  }

  // ---------------------------------------------------------------------------
  // Factions
  // ---------------------------------------------------------------------------
  List<Widget> _buildFactionDetail(
      ThemeData theme, Map<String, dynamic> item, String description) {
    final widgets = <Widget>[];

    // Description
    if (description.isNotEmpty) {
      widgets.add(_detailSectionText(theme, description));
      widgets.add(const SizedBox(height: 16));
    }

    // Primary location
    if (item['primaryLocation'] != null) {
      widgets.add(
        _infoRow(theme, Icons.place, 'Primary Location',
            item['primaryLocation'] as String),
      );
      widgets.add(const SizedBox(height: 14));
    }

    // Reputation tiers
    if (item['reputationTiers'] != null) {
      final tiers = item['reputationTiers'] as List<dynamic>;
      widgets.add(
        Text(
          'Reputation Tiers',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));
      for (final tier in tiers) {
        final tierName = tier['name'] as String? ?? '';
        final tierDesc = tier['description'] as String? ?? '';
        final tierBenefits = tier['benefits'] as String? ?? '';
        widgets.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tierName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade300,
                  ),
                ),
                if (tierDesc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tierDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (tierBenefits.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tierBenefits,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: Colors.green.shade300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Missions
  // ---------------------------------------------------------------------------
  List<Widget> _buildMissionDetail(
      ThemeData theme, Map<String, dynamic> item, String description) {
    final widgets = <Widget>[];

    // Description
    if (description.isNotEmpty) {
      widgets.add(_detailSectionText(theme, description));
      widgets.add(const SizedBox(height: 16));
    }

    // Minimum rep tier
    if (item['minRepTier'] != null) {
      widgets.add(
        _infoRow(theme, Icons.stars, 'Minimum Rep Tier',
            item['minRepTier'] as String),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Reward range
    if (item['rewardRange'] != null) {
      final range = item['rewardRange'] as Map<String, dynamic>;
      final min = (range['min'] as num?)?.toInt() ?? 0;
      final max = (range['max'] as num?)?.toInt() ?? 0;
      widgets.add(
        _infoRow(theme, Icons.redeem, 'Reward Range', '$min - $max aUEC'),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Locations list
    if (item['locations'] != null) {
      final locs = item['locations'] as List<dynamic>;
      final locStr = locs.join(', ');
      widgets.add(
        _infoRow(theme, Icons.place, 'Locations', locStr),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Faction requirements
    if (item['factionRequirements'] != null) {
      final factions = item['factionRequirements'] as List<dynamic>;
      final factionStr = factions.join(', ');
      widgets.add(
        _infoRow(theme, Icons.group, 'Faction Requirements', factionStr),
      );
      widgets.add(const SizedBox(height: 10));
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Commodities
  // ---------------------------------------------------------------------------
  List<Widget> _buildCommodityDetail(ThemeData theme, Map<String, dynamic> item,
      String description, String typeLabel, Color typeColor) {
    final widgets = <Widget>[];

    // Average price
    if (item['averagePrice'] != null) {
      final price = (item['averagePrice'] as num).toDouble();
      widgets.add(
        _infoRow(theme, Icons.attach_money, 'Average Price',
            '\$${price.toStringAsFixed(2)}'),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Bulk size
    if (item['bulkSize'] != null) {
      final bulk = item['bulkSize'] as int;
      widgets.add(
        _infoRow(theme, Icons.inventory, 'Bulk Size', '${bulk}x'),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Legality warning
    if (item['isIllegal'] == true) {
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: Colors.red.shade300),
              const SizedBox(width: 8),
              Text(
                'Illegal Commodity',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.red.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Description
    if (description.isNotEmpty) {
      widgets.add(_detailSectionText(theme, description));
      widgets.add(const SizedBox(height: 10));
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Locations
  // ---------------------------------------------------------------------------
  List<Widget> _buildLocationDetail(
      ThemeData theme, Map<String, dynamic> item, String description) {
    final widgets = <Widget>[];

    // Planet
    if (item['planet'] != null) {
      widgets.add(
        _infoRow(theme, Icons.public, 'Planet', item['planet'] as String),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Description
    if (description.isNotEmpty) {
      widgets.add(_detailSectionText(theme, description));
      widgets.add(const SizedBox(height: 16));
    }

    // Services as icon chips
    if (item['services'] != null) {
      final services = item['services'] as List<dynamic>;
      widgets.add(
        Text(
          'Services',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));
      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services.map((service) {
            return _serviceChip(theme, service as String);
          }).toList(),
        ),
      );
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Default
  // ---------------------------------------------------------------------------
  List<Widget> _buildDefaultDetail(
      ThemeData theme, Map<String, dynamic> item, String description) {
    final widgets = <Widget>[];

    // Description
    if (description.isNotEmpty) {
      widgets.add(_detailSectionText(theme, description));
      widgets.add(const SizedBox(height: 16));
    }

    // All remaining fields as key-value pairs
    final excludedKeys = {'name', 'description', 'type', 'id'};
    final entries = item.entries
        .where((e) => !excludedKeys.contains(e.key))
        .toList();

    if (entries.isNotEmpty) {
      for (final entry in entries) {
        String valueStr;
        if (entry.value is List) {
          valueStr = (entry.value as List).join(', ');
        } else if (entry.value is Map) {
          valueStr = (entry.value as Map).entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ');
        } else {
          valueStr = entry.value.toString();
        }

        final label = entry.key.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (m) => ' ${m.group(0)}',
        );
        final displayLabel =
            label[0].toUpperCase() + label.substring(1);

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    displayLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    valueStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _detailSectionText(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        height: 1.5,
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: categoryIconColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

  /// Resolves a human-readable type label based on the item's fields.
  String _resolveTypeLabel(Map<String, dynamic> item) {
    if (item['type'] != null) {
      final raw = item['type'] as String;
      return raw.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');
    }
    if (item['minRepTier'] != null) {
      return item['minRepTier'] as String;
    }
    if (item['averagePrice'] != null) {
      final price = (item['averagePrice'] as num).toDouble();
      return '\$${price.toStringAsFixed(2)}';
    }
    if (item['isIllegal'] == true) {
      return 'Illegal';
    }
    return '';
  }

  /// Resolves a color for the type badge.
  Color _resolveTypeColor(Map<String, dynamic> item) {
    if (item['isIllegal'] == true) {
      return Colors.red.shade400;
    }
    if (item['type'] != null) {
      final type = (item['type'] as String).toLowerCase();
      if (type.contains('bounty') || type.contains('combat')) {
        return Colors.red.shade400;
      }
      if (type.contains('delivery') || type.contains('transport')) {
        return Colors.amber.shade400;
      }
      if (type.contains('mine') || type.contains('raw')) {
        return Colors.orange.shade400;
      }
      if (type.contains('govt') || type.contains('law')) {
        return Colors.cyan.shade400;
      }
      if (type.contains('planet') || type.contains('station')) {
        return Colors.green.shade400;
      }
    }
    return categoryIconColor;
  }

  /// Whether this item has extra details to show (price, reward, services).
  bool _hasExtraDetail(Map<String, dynamic> item) {
    return item['averagePrice'] != null ||
        item['rewardRange'] != null ||
        item['services'] != null ||
        item['reputationTiers'] != null;
  }

  /// Builds a row of extra detail chips.
  Widget _buildExtraDetailRow(ThemeData theme, Map<String, dynamic> item) {
    final chips = <Widget>[];

    // Price for commodities
    if (item['averagePrice'] != null) {
      final price = (item['averagePrice'] as num).toDouble();
      chips.add(_detailChip(
        theme,
        Icons.attach_money,
        '\$${price.toStringAsFixed(2)}',
        categoryIconColor,
      ));
    }

    // Reward range for missions
    if (item['rewardRange'] != null) {
      final range = item['rewardRange'] as Map<String, dynamic>;
      final min = (range['min'] as num?)?.toInt() ?? 0;
      final max = (range['max'] as num?)?.toInt() ?? 0;
      chips.add(_detailChip(
        theme,
        Icons.redeem,
        '$min-$max aUEC',
        Colors.amber.shade400,
      ));
    }

    // Services for locations
    if (item['services'] != null) {
      final services = item['services'] as List<dynamic>;
      final serviceCount = services.length;
      chips.add(_detailChip(
        theme,
        Icons.miscellaneous_services,
        '$serviceCount services',
        Colors.green.shade400,
      ));
    }

    // Reputation tiers for factions
    if (item['reputationTiers'] != null) {
      final tiers = item['reputationTiers'] as List<dynamic>;
      chips.add(_detailChip(
        theme,
        Icons.stars,
        '${tiers.length} rep tiers',
        Colors.amber.shade400,
      ));
    }

    // Bulk size for commodities
    if (item['bulkSize'] != null) {
      final bulk = item['bulkSize'] as int;
      chips.add(_detailChip(
        theme,
        Icons.inventory,
        '${bulk}x bulk',
        categoryIconColor,
      ));
    }

    // Locations for missions
    if (item['locations'] != null) {
      final locs = item['locations'] as List<dynamic>;
      chips.add(_detailChip(
        theme,
        Icons.place,
        locs.join(', '),
        Colors.cyan.shade400,
      ));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _detailChip(
    ThemeData theme,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
