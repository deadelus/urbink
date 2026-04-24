import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Card statistique réutilisable (valeur + label) pour le SessionMonitor.
class SessionStatCard extends StatelessWidget {
  final String value;
  final String label;

  /// Si true, la valeur s'affiche en colorScheme.primary (métrique mise en avant).
  final bool highlight;

  const SessionStatCard({
    super.key,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: UrbinkColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: UrbinkTypography.bodyFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: highlight ? primary : UrbinkColors.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: UrbinkTypography.bodyFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: UrbinkColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
