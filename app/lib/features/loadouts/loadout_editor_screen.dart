import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/data/reference_database.dart';
import 'package:sc_synthesis/core/data/rust_database_service.dart';
import 'package:sc_synthesis/core/widgets/ship_image.dart';
import 'package:sc_synthesis/features/loadouts/loadout_data.dart';
import 'package:sc_synthesis/src/rust/api/model.dart';

/// Main loadout builder screen — pick a ship, then slot components.
class LoadoutEditorScreen extends StatefulWidget {
  final Loadout? existingLoadout;

  const LoadoutEditorScreen({super.key, this.existingLoadout});

  @override
  State<LoadoutEditorScreen> createState() => _LoadoutEditorScreenState();
}

class _LoadoutEditorScreenState extends State<LoadoutEditorScreen> {
  final _db = ReferenceDatabase();
  final _shipService = RustDatabaseService();
  final _loadoutService = LoadoutService();

  Loadout? _loadout;
  List<Ship> _ships = [];
  List<Ship> _filteredShips = [];
  bool _loadingShips = true;
  bool _showShipPicker = true;
  String _searchQuery = '';
  String _name = '';
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingLoadout?.name ?? '';
    _loadout = widget.existingLoadout;
    if (_loadout != null) {
      _loadout!.resolveComponents(_db);
      _showShipPicker = false;
      _name = _loadout!.name;
    }
    _loadShips();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadShips() async {
    try {
      await _shipService.init();
      final ships = await _shipService.getAllShips();
      if (mounted) {
        setState(() {
          _ships = ships;
          _loadingShips = false;
          _applyFilter();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingShips = false);
    }
  }

  void _applyFilter() {
    final q = _searchQuery.toLowerCase();
    setState(() {
      _filteredShips = _ships.where((s) {
        if (q.isEmpty) return true;
        return s.name.toLowerCase().contains(q) ||
            s.manufacturer.toLowerCase().contains(q) ||
            s.classification.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _selectShip(Ship ship) {
    setState(() {
      _loadout = Loadout(
        id: widget.existingLoadout?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        shipId: ship.id,
        shipName: ship.name,
        shipSlug: ship.slug,
        name: _name.isNotEmpty ? _name : '${ship.name} Loadout',
      );
      _name = _loadout!.name;
      _nameController.text = _loadout!.name;
      _showShipPicker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_loadout != null ? _loadout!.shipName : 'New Loadout'),
        centerTitle: true,
        actions: [
          if (_loadout != null && !_showShipPicker)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save Loadout',
              onPressed: _saveLoadout,
            ),
        ],
      ),
      body: _showShipPicker ? _buildShipPicker(theme) : _buildEditor(theme),
    );
  }

  Widget _buildShipPicker(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search ships...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) {
              _searchQuery = v;
              _applyFilter();
            },
          ),
        ),
        Expanded(
          child: _loadingShips
              ? const Center(child: CircularProgressIndicator())
              : _filteredShips.isEmpty
                  ? Center(
                      child: Text(
                        'No ships found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _filteredShips.length,
                      itemBuilder: (ctx, i) => _buildShipCard(
                          theme, _filteredShips[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildShipCard(ThemeData theme, Ship ship) {
    final size = ship.size;
    final sizeColor = size == 'Small'
        ? Colors.green.shade400
        : size == 'Medium'
            ? Colors.orange.shade400
            : Colors.red.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _selectShip(ship),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ShipAvatar(
                manufacturer: ship.manufacturer,
                slug: ship.slug,
                size: 48,
              ),
              const SizedBox(width: 12),
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
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sizeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ship.classification,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: sizeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    if (_loadout == null) return const SizedBox();

    return Column(
      children: [
        // Loadout name + ship info header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.08),
                theme.colorScheme.primary.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ShipAvatar(
                    manufacturer: _loadout!.shipSlug,
                    slug: _loadout!.shipSlug,
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loadout!.shipName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Loadout name',
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          style: theme.textTheme.bodySmall,
                          onChanged: (v) => _name = v,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    tooltip: 'Change ship',
                    onPressed: () => setState(() => _showShipPicker = true),
                  ),
                ],
              ),
              if (_loadout!.totalCost > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money,
                        size: 14,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Total: \$${_loadout!.totalCost.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Component slots
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: _loadout!.slots.map((slot) {
              return _buildSlotCard(theme, slot);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(ThemeData theme, LoadoutSlot slot) {
    final icon = _slotIcon(slot.category);
    final color = _slotColor(slot.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: slot.componentData != null
              ? color.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openComponentPicker(slot),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot.componentData != null
                          ? '${slot.componentData!['name']} — ${slot.componentData!['grade'] ?? ''}/${slot.componentData!['size'] ?? ''}'
                          : 'Empty — tap to select',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: slot.componentData != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: slot.componentData != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (slot.componentData != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      slot.componentId = null;
                      slot.componentData = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        size: 16,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.3)),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }

  void _openComponentPicker(LoadoutSlot slot) async {
    final allComponents = _db.components
        .where((c) => c['category'] == slot.category)
        .toList();

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => _ComponentPickerScreen(
          category: slot.category,
          slotLabel: slot.label,
          components: allComponents,
          currentId: slot.componentId,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        slot.componentId = result['id'] as String;
        slot.componentData = result;
      });
    }
  }

  Future<void> _saveLoadout() async {
    if (_loadout == null) return;
    _loadout!.name = _name.isNotEmpty ? _name : _loadout!.shipName;

    if (widget.existingLoadout != null) {
      await _loadoutService.updateLoadout(_loadout!);
    } else {
      await _loadoutService.addLoadout(_loadout!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "${_loadout!.name}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  static IconData _slotIcon(String category) {
    switch (category) {
      case 'weapons':
        return Icons.gps_fixed;
      case 'shieldgenerator':
        return Icons.shield;
      case 'powerplant':
        return Icons.bolt;
      case 'cooler':
        return Icons.ac_unit;
      case 'quantumdrive':
        return Icons.rocket;
      case 'radar':
        return Icons.radar;
      default:
        return Icons.build;
    }
  }

  static Color _slotColor(String category) {
    switch (category) {
      case 'weapons':
        return Colors.red.shade400;
      case 'shieldgenerator':
        return Colors.cyan.shade400;
      case 'powerplant':
        return Colors.amber.shade400;
      case 'cooler':
        return Colors.lightBlue.shade400;
      case 'quantumdrive':
        return Colors.purple.shade400;
      case 'radar':
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }
}

// ---------------------------------------------------------------------------
// Component picker screen — filters + selects one component
// ---------------------------------------------------------------------------

class _ComponentPickerScreen extends StatefulWidget {
  final String category;
  final String slotLabel;
  final List<Map<String, dynamic>> components;
  final String? currentId;

  const _ComponentPickerScreen({
    required this.category,
    required this.slotLabel,
    required this.components,
    this.currentId,
  });

  @override
  State<_ComponentPickerScreen> createState() =>
      _ComponentPickerScreenState();
}

class _ComponentPickerScreenState extends State<_ComponentPickerScreen> {
  String _sortBy = 'grade'; // grade, size, name
  String _sizeFilter = '';
  String _searchQuery = '';
  List<Map<String, dynamic>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    final q = _searchQuery.toLowerCase();
    final sizes =
        _sizeFilter.isNotEmpty ? _sizeFilter.split(',') : <String>[];
    setState(() {
      _filtered = widget.components.where((c) {
        if (q.isNotEmpty &&
            !(c['name'] as String).toLowerCase().contains(q) &&
            !(c['manufacturer'] as String).toLowerCase().contains(q)) {
          return false;
        }
        if (sizes.isNotEmpty &&
            !sizes.contains((c['size'] as String?) ?? '')) {
          return false;
        }
        return true;
      }).toList();
      _sortComponents();
    });
  }

  void _sortComponents() {
    switch (_sortBy) {
      case 'grade':
        _filtered.sort((a, b) {
          return _gradeValue(b['grade'] as String? ?? '').compareTo(
              _gradeValue(a['grade'] as String? ?? ''));
        });
        break;
      case 'size':
        _filtered.sort((a, b) {
          return (_sizeValue(a['size'] as String? ?? '')).compareTo(
              _sizeValue(b['size'] as String? ?? ''));
        });
        break;
      case 'name':
        _filtered.sort((a, b) => (a['name'] as String)
            .compareTo(b['name'] as String));
        break;
    }
  }

  int _gradeValue(String grade) {
    switch (grade.toUpperCase()) {
      case 'S':
        return 6;
      case 'A':
        return 5;
      case 'B':
        return 4;
      case 'C':
        return 3;
      case 'D':
        return 2;
      default:
        return 1;
    }
  }

  int _sizeValue(String size) {
    final n = int.tryParse(size);
    return n ?? 0;
  }

  List<String> get _availableSizes {
    final sizes =
        widget.components.map((c) => c['size'] as String? ?? '').toSet();
    return sizes.where((s) => s.isNotEmpty).toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _slotColor(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.slotLabel}'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, size: 20),
            onSelected: (v) {
              _sortBy = v;
              _applyFilters();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'grade',
                child: Row(
                  children: [
                    Icon(Icons.star,
                        size: 16,
                        color: _sortBy == 'grade'
                            ? color
                            : null),
                    const SizedBox(width: 8),
                    const Text('Grade (best first)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'size',
                child: Row(
                  children: [
                    Icon(Icons.straighten,
                        size: 16,
                        color: _sortBy == 'size'
                            ? color
                            : null),
                    const SizedBox(width: 8),
                    const Text('Size'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                        size: 16,
                        color: _sortBy == 'name'
                            ? color
                            : null),
                    const SizedBox(width: 8),
                    const Text('Name'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + size filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon:
                          const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) {
                      _searchQuery = v;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (_availableSizes.length > 1)
                  DropdownButton<String>(
                    value: _sizeFilter,
                    hint: const Text('Size',
                        style: TextStyle(fontSize: 12)),
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text('All',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface)),
                      ),
                      ..._availableSizes.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('S$s',
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        theme.colorScheme.onSurface)),
                          )),
                    ],
                    onChanged: (v) {
                      _sizeFilter = v ?? '';
                      _applyFilters();
                    },
                    underline: const SizedBox(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} components',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) =>
                  _buildComponentCard(theme, _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(
      ThemeData theme, Map<String, dynamic> comp) {
    final isSelected = comp['id'] == widget.currentId;
    final name = comp['name'] as String? ?? '';
    final manufacturer = comp['manufacturer'] as String? ?? '';
    final grade = comp['grade'] as String? ?? '';
    final size = comp['size'] as String? ?? '';
    final itemClass = comp['itemClassLabel'] as String? ?? '';

    final gradeColor = switch (grade.toUpperCase()) {
      'S' => Colors.purple.shade400,
      'A' => Colors.red.shade400,
      'B' => Colors.orange.shade400,
      'C' => Colors.blue.shade400,
      'D' => Colors.grey.shade400,
      _ => Colors.grey.shade400,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? _slotColor(widget.category).withValues(alpha: 0.6)
              : theme.colorScheme.onSurface.withValues(alpha: 0.06),
          width: isSelected ? 2 : 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).pop(comp),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: gradeColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          manufacturer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        if (itemClass.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            itemClass,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Grade badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  grade,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: gradeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Size badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'S$size',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle,
                    size: 18, color: gradeColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _slotColor(String category) {
    switch (category) {
      case 'weapons':
        return Colors.red.shade400;
      case 'shieldgenerator':
        return Colors.cyan.shade400;
      case 'powerplant':
        return Colors.amber.shade400;
      case 'cooler':
        return Colors.lightBlue.shade400;
      case 'quantumdrive':
        return Colors.purple.shade400;
      case 'radar':
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }
}
