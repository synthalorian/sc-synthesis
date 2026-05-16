import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/reference_database.dart';

/// A commodity type filter option.
enum _CommodityFilter { all, raw, gas, processed, refined, agricultural, medical, waste }

/// Sort mode for the commodity list.
enum _SortMode { pricePerScu, bulkSize, name }

/// Trade Route Calculator / Commodity Rankings screen.
///
/// Loads all commodities from [ReferenceDatabase], computes profitability
/// (price per SCU = averagePrice / bulkSize), and presents them in a ranked
/// list with filtering, search, and sort capabilities.
class TradeRoutesScreen extends StatefulWidget {
  const TradeRoutesScreen({super.key});

  @override
  State<TradeRoutesScreen> createState() => _TradeRoutesScreenState();
}

class _TradeRoutesScreenState extends State<TradeRoutesScreen> {
  final ReferenceDatabase _db = ReferenceDatabase();
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _allCommodities = [];
  List<_CommodityEntry> _entries = [];
  List<_CommodityEntry> _filteredEntries = [];

  String _searchQuery = '';
  _CommodityFilter _filter = _CommodityFilter.all;
  _SortMode _sortMode = _SortMode.pricePerScu;

  // Color mapping for commodity types (synthwave neon palette)
  static const Map<String, Color> _typeColors = {
    'raw': Color(0xFFFF8C00), // orange
    'gas': Color(0xFFB57EDC), // purple
    'processed': Color(0xFF00BFA5), // teal
    'refined': Color(0xFF2196F3), // blue
    'agricultural': Color(0xFF4CAF50), // green
    'medical': Color(0xFFE53935), // red
    'waste': Color(0xFF8D6E63), // brown
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _db.load();
      if (mounted) {
        setState(() {
          _allCommodities = List<Map<String, dynamic>>.from(_db.commodities);
          _entries = _allCommodities.map((c) => _CommodityEntry._fromMap(c)).toList();
          _loading = false;
          _applyFiltersAndSort();
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

  void _applyFiltersAndSort() {
    var result = List<_CommodityEntry>.from(_entries);

    // Filter by type
    if (_filter != _CommodityFilter.all) {
      final typeStr = _filter.name;
      result = result.where((e) => e.type == typeStr).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    // Sort
    switch (_sortMode) {
      case _SortMode.pricePerScu:
        result.sort((a, b) => b.pricePerScu.compareTo(a.pricePerScu));
        break;
      case _SortMode.bulkSize:
        result.sort((a, b) => b.bulkSize.compareTo(a.bulkSize));
        break;
      case _SortMode.name:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    setState(() {
      _filteredEntries = result;
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _applyFiltersAndSort();
  }

  void _onFilterChanged(_CommodityFilter filter) {
    setState(() {
      _filter = filter;
    });
    _applyFiltersAndSort();
  }

  void _onSortChanged(_SortMode? mode) {
    if (mode == null) return;
    setState(() {
      _sortMode = mode;
    });
    _applyFiltersAndSort();
  }

  void _showDetails(BuildContext context, _CommodityEntry entry) {
    final theme = Theme.of(context);
    final color = _typeColors[entry.type] ?? Colors.grey;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.95),
              theme.colorScheme.surface,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: color.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name + type badge row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                entry.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (entry.isIllegal) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildBadge(entry.type, color),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  _buildStatChip(
                    theme,
                    Icons.trending_up,
                    'Price / SCU',
                    '\$${entry.pricePerScu.toStringAsFixed(1)}',
                    color,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    theme,
                    Icons.inventory_outlined,
                    'Bulk Size',
                    '${entry.bulkSize} SCU',
                    color,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    theme,
                    Icons.attach_money,
                    'Avg Price',
                    '\$${entry.averagePrice.toStringAsFixed(2)}',
                    color,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              if (entry.description.isNotEmpty) ...[
                Text(
                  'Description',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],

              if (entry.isIllegal) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Illegal commodity — may be confiscated at security checkpoints.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Routes'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load commodities',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.tonal(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _load();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    _buildSearchBar(theme),
                    // Filter chips
                    _buildFilterChips(theme),
                    // Sort selector
                    _buildSortSelector(theme),
                    // Commodity count + illegal warning
                    _buildSummaryBar(theme),
                    // Commodity list
                    Expanded(child: _buildCommodityList(theme)),
                  ],
                ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: _onSearchChanged,
        style: TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search commodities...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.4), size: 18),
                  onPressed: () {
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.secondary.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final chips = _CommodityFilter.values;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = _filter == chip;
          final chipColor = chip == _CommodityFilter.all
              ? theme.colorScheme.secondary
              : _typeColors[chip.name] ?? Colors.grey;

          return GestureDetector(
            onTap: () => _onFilterChanged(chip),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          chipColor.withValues(alpha: 0.25),
                          chipColor.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: isSelected ? null : theme.colorScheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? chipColor.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Text(
                _filterLabel(chip),
                style: TextStyle(
                  color: isSelected ? chipColor : Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.sort, size: 16, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(width: 8),
          Text(
            'Sort by:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          _buildSortChip(theme, _SortMode.pricePerScu, 'Price/SCU'),
          const SizedBox(width: 6),
          _buildSortChip(theme, _SortMode.bulkSize, 'Bulk Size'),
          const SizedBox(width: 6),
          _buildSortChip(theme, _SortMode.name, 'Name'),
        ],
      ),
    );
  }

  Widget _buildSortChip(ThemeData theme, _SortMode mode, String label) {
    final isSelected = _sortMode == mode;
    final color = theme.colorScheme.secondary;

    return GestureDetector(
      onTap: () => _onSortChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 3),
              Icon(
                mode == _SortMode.name ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(ThemeData theme) {
    final illegalCount = _filteredEntries.where((e) => e.isIllegal).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '${_filteredEntries.length} commodities',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          if (illegalCount > 0) ...[
            const SizedBox(width: 8),
            Icon(Icons.warning_amber_rounded, size: 12, color: Colors.amber.withValues(alpha: 0.6)),
            const SizedBox(width: 3),
            Text(
              '$illegalCount illegal',
              style: TextStyle(
                color: Colors.amber.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommodityList(ThemeData theme) {
    if (_filteredEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  Icons.search_off,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No commodities found',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try adjusting your filters or search query.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) => _buildCommodityCard(theme, _filteredEntries[index]),
    );
  }

  Widget _buildCommodityCard(ThemeData theme, _CommodityEntry entry) {
    final color = _typeColors[entry.type] ?? Colors.grey;
    final rank = _filteredEntries.indexOf(entry) + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showDetails(context, entry),
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Rank number
                if (_sortMode == _SortMode.pricePerScu)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: color.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (_sortMode == _SortMode.pricePerScu) const SizedBox(width: 10),

                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.inventory_2, size: 20, color: color),
                ),
                const SizedBox(width: 12),

                // Name, badge, secondary info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.isIllegal) ...[
                            const SizedBox(width: 5),
                            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(entry.type, color),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.bulkSize} SCU',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${entry.averagePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Price per SCU (big number)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${entry.pricePerScu.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '/ SCU',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String type, Color color) {
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
        type[0].toUpperCase() + type.substring(1),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _filterLabel(_CommodityFilter filter) {
    switch (filter) {
      case _CommodityFilter.all:
        return 'All';
      case _CommodityFilter.raw:
        return 'Raw';
      case _CommodityFilter.gas:
        return 'Gas';
      case _CommodityFilter.processed:
        return 'Processed';
      case _CommodityFilter.refined:
        return 'Refined';
      case _CommodityFilter.agricultural:
        return 'Agricultural';
      case _CommodityFilter.medical:
        return 'Medical';
      case _CommodityFilter.waste:
        return 'Waste';
    }
  }
}

/// Parsed commodity entry with computed pricePerScu.
class _CommodityEntry {
  final String id;
  final String name;
  final String type;
  final String description;
  final double averagePrice;
  final int bulkSize;
  final bool isIllegal;
  final double pricePerScu;

  const _CommodityEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.averagePrice,
    required this.bulkSize,
    required this.isIllegal,
    required this.pricePerScu,
  });

  factory _CommodityEntry._fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String? ?? '';
    final name = map['name'] as String? ?? 'Unknown';
    final type = map['type'] as String? ?? 'raw';
    final description = map['description'] as String? ?? '';
    final averagePrice = (map['averagePrice'] as num?)?.toDouble() ?? 0.0;
    final bulkSize = (map['bulkSize'] as num?)?.toInt() ?? 1;
    final isIllegal = map['isIllegal'] as bool? ?? false;
    final pricePerScu = bulkSize > 0 ? averagePrice / bulkSize : 0.0;

    return _CommodityEntry(
      id: id,
      name: name,
      type: type,
      description: description,
      averagePrice: averagePrice,
      bulkSize: bulkSize,
      isIllegal: isIllegal,
      pricePerScu: pricePerScu,
    );
  }
}
