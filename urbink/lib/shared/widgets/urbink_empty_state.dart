import 'package:flutter/material.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/urbink_button.dart';

/// Empty state Urbink conforme Story 1.4.
///
/// Affiche : illustration emoji + titre ≤ 2 lignes + CTA optionnel.
/// Jamais un écran blanc ou un message d'erreur générique.
///
/// Usage :
/// ```dart
/// UrbinkEmptyState(
///   emoji: '🗺️',
///   title: 'Aucun itinéraire pour l\'instant',
///   subtitle: 'Crée ton premier itinéraire et explore Paris à ta façon.',
///   ctaLabel: 'Créer un itinéraire',
///   onCta: () { ... },
/// )
/// ```
class UrbinkEmptyState extends StatelessWidget {
  const UrbinkEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final String emoji;
  final String title;
  final String? subtitle;

  /// Label du bouton CTA — requis si [onCta] est fourni.
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UrbinkSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: UrbinkSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: UrbinkSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: UrbinkSpacing.lg),
              UrbinkButton(
                label: ctaLabel!,
                onPressed: onCta,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
