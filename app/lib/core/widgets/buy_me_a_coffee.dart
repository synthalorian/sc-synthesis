import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String bmacUrl = 'https://buymeacoffee.com/synthalorian';

void openBuyMeACoffee() async {
  final uri = Uri.parse(bmacUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class BuyMeACoffeeButton extends StatelessWidget {
  final bool compact;
  const BuyMeACoffeeButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return InkWell(
        onTap: openBuyMeACoffee,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('☕', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Buy me a coffee',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          const Text('☕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Support Development',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'If SC:Synthesis helps you in the \'verse,\nconsider buying me a coffee!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: openBuyMeACoffee,
            icon: const Text('☕', style: TextStyle(fontSize: 18)),
            label: const Text('Buy me a coffee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDD00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
