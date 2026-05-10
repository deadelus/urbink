import 'package:flutter/material.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';

// ---------------------------------------------------------------------------
// ObjectifCard — carte d'un objectif thématique dans l'onglet Objectifs
// ---------------------------------------------------------------------------

class ObjectifCard extends StatelessWidget {
  const ObjectifCard({
    super.key,
    required this.collection,
    required this.isActive,
    required this.onTap,
    required this.onToggleActivation,
  });

  final MonumentCollection collection;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onToggleActivation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = collection.stats;
    final isComplete = stats.pct == 100;
    final progressValue = stats.total > 0 ? stats.unlocked / stats.total : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? collection.color.withValues(alpha: 0.5)
                : UrbinkColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header : emoji + titre + pills transport
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.icon,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: UrbinkColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        collection.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: UrbinkColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Pills transport
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: collection.transportModes
                      .map((mode) => _TransportPill(mode: mode, l10n: l10n))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barre de progression
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          backgroundColor: isComplete
                              ? collection.color.withValues(alpha: 0.2)
                              : UrbinkColors.ghost,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isComplete
                                ? collection.color
                                : collection.color.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.objectif_progress(stats.unlocked, stats.total),
                        style: TextStyle(
                          fontSize: 11,
                          color: isComplete
                              ? collection.color
                              : UrbinkColors.navInactive,
                          fontWeight: isComplete
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Bouton activation
                _ActivateButton(
                  isActive: isActive,
                  isComplete: isComplete,
                  color: collection.color,
                  onTap: onToggleActivation,
                  l10n: l10n,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TransportPill
// ---------------------------------------------------------------------------

class _TransportPill extends StatelessWidget {
  const _TransportPill({required this.mode, required this.l10n});

  final String mode;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = switch (mode) {
      'bike' => ('🚲', l10n.transport_bike),
      'all' => ('🚶🚲', l10n.transport_all),
      _ => ('🚶', l10n.transport_foot),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: UrbinkColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$emoji $label',
        style: const TextStyle(fontSize: 10, color: UrbinkColors.navInactive),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ActivateButton
// ---------------------------------------------------------------------------

class _ActivateButton extends StatelessWidget {
  const _ActivateButton({
    required this.isActive,
    required this.isComplete,
    required this.color,
    required this.onTap,
    required this.l10n,
  });

  final bool isActive;
  final bool isComplete;
  final Color color;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '✅ ${l10n.objectif_complete}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );
    }

    if (isActive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.objectif_deactivate,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          l10n.objectif_activate,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
