import 'package:flutter/material.dart';

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
                  _buildItemCard(theme, items[index]),
            ),
    );
  }

  Widget _buildItemCard(ThemeData theme, Map<String, dynamic> item) {
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
