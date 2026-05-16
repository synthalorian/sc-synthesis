import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/widgets/ship_image.dart';
import 'package:sc_synthesis/features/loadouts/loadout_data.dart';
import 'package:sc_synthesis/features/loadouts/loadout_editor_screen.dart';

/// List of saved loadouts — view, edit, duplicate, delete.
class LoadoutListScreen extends StatefulWidget {
  const LoadoutListScreen({super.key});

  @override
  State<LoadoutListScreen> createState() => _LoadoutListScreenState();
}

class _LoadoutListScreenState extends State<LoadoutListScreen> {
  final _service = LoadoutService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    _init();
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _init() async {
    await _service.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loadouts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            tooltip: 'New Loadout',
            onPressed: () => _openEditor(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _service.loadouts.isEmpty
              ? _buildEmpty(theme)
              : _buildList(theme),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
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
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.build_circle_outlined,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Loadouts Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build your first ship loadout.\nPick a ship, slot components, save it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Loadout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _service.loadouts.length,
        itemBuilder: (ctx, i) => _buildLoadoutCard(theme, _service.loadouts[i]),
      ),
    );
  }

  Widget _buildLoadoutCard(ThemeData theme, Loadout loadout) {
    final filledSlots = loadout.slots.where((s) => s.componentId != null).length;
    final totalSlots = loadout.slots.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openEditor(loadout: loadout),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ShipAvatar(
                manufacturer: loadout.shipSlug,
                slug: loadout.shipSlug,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loadout.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loadout.shipName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.build,
                            size: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          '$filledSlots/$totalSlots slots',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        if (loadout.totalCost > 0) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.attach_money,
                              size: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                          const SizedBox(width: 2),
                          Text(
                            '\$${loadout.totalCost.toStringAsFixed(0)}',
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
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 18,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4)),
                onSelected: (v) async {
                  switch (v) {
                    case 'edit':
                      _openEditor(loadout: loadout);
                      break;
                    case 'duplicate':
                      await _service.duplicateLoadout(loadout.id);
                      break;
                    case 'delete':
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Loadout'),
                          content: Text(
                              'Delete "${loadout.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _service.deleteLoadout(loadout.id);
                      }
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor({Loadout? loadout}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoadoutEditorScreen(existingLoadout: loadout),
      ),
    );
  }
}
