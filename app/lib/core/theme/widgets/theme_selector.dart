import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/theme/app_theme.dart';

/// A screen that lets the user pick their theme.
///
/// Accepts [currentType] so the selected state is accurate —
/// avoids comparing ThemeData objects by reference (which always fails).
class ThemeSelectorScreen extends StatelessWidget {
  final AppThemeType currentType;

  const ThemeSelectorScreen({super.key, required this.currentType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Choose your aesthetic',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...AppThemeType.values.map(
            (type) => _ThemeCard(
              type: type,
              isSelected: type == currentType,
              onTap: () => Navigator.of(context).pop(type),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = type.themeData;
    final accent = type.previewColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isSelected
            ? BorderSide(color: accent, width: 2.5)
            : BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                width: 1,
              ),
      ),
      elevation: isSelected ? 4 : 1,
      shadowColor: isSelected ? accent.withValues(alpha: 0.3) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Theme preview swatch — shows actual theme colors
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: preview.scaffoldBackgroundColor,
                  border: Border.all(
                    color: preview.colorScheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(type.icon, color: accent, size: 26),
                ),
              ),
              const SizedBox(width: 16),

              // Name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accent : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Color swatches row
                    Row(
                      children: [
                        _swatch(accent),
                        const SizedBox(width: 6),
                        _swatch(preview.colorScheme.secondary),
                        const SizedBox(width: 6),
                        _swatch(preview.colorScheme.tertiary),
                        const SizedBox(width: 6),
                        _swatch(preview.colorScheme.error),
                      ],
                    ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.15),
                  ),
                  child: Icon(Icons.check_circle, color: accent, size: 28),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }
}