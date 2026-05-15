import 'package:flutter/material.dart';

/// A shimmer/placeholder loading widget for the synthwave aesthetic.
/// Renders animated gradient bars instead of a boring spinner.
class ShimmerLoading extends StatefulWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  const ShimmerLoading({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 88,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller; // ignore: unused_field

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        return ListView.builder(
          padding: widget.padding,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            // Stagger shimmer across items
            final stagger = (progress + index * 0.18) % 1.0;
            final shimmerPos = stagger * 2.0 - 0.5;

            return _ShimmerItem(
              height: widget.itemHeight,
              shimmerPos: shimmerPos,
              theme: theme,
            );
          },
        );
      },
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  final double height;
  final double shimmerPos;
  final ThemeData theme;

  const _ShimmerItem({
    required this.height,
    required this.shimmerPos,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = theme.colorScheme.surface;
    final highlightColor = theme.colorScheme.primary.withValues(alpha: 0.08);
    final shimmerColor = theme.colorScheme.primary.withValues(alpha: 0.18);

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment(shimmerPos - 0.5, 0),
          end: Alignment(shimmerPos + 0.5, 0),
          colors: [
            baseColor,
            highlightColor,
            shimmerColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 14,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 120,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
