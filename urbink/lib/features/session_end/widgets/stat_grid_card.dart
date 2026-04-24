import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Carte statistique pour la grille 2×2 du SessionSummarySheet.
class StatGridCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String unit;

  const StatGridCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: UrbinkColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: UrbinkTypography.displayFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: primary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontFamily: UrbinkTypography.bodyFamily,
              fontSize: 11,
              color: UrbinkColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
