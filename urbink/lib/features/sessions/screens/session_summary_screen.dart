import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';

/// Écran récapitulatif affiché après l'arrêt d'une session circuit libre.
///
/// Affiche : rues explorées, distance, durée, mode de déplacement.
/// Hors scope Story 2.5 : badge animation, carte miniature tracé (→ Story 3.x).
class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final duration = session.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final durationLabel =
        hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';

    final distanceLabel = session.distanceKm >= 1.0
        ? '${session.distanceKm.toStringAsFixed(2)} km'
        : '${session.distanceMeters.toStringAsFixed(0)} m';

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: UrbinkColors.surface,
      appBar: AppBar(
        backgroundColor: UrbinkColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.session_completed,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: UrbinkColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UrbinkSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: UrbinkSpacing.md),
              _StatRow(
                emoji: '🛣️',
                label: l10n.stat_streets,
                value: '${session.streetCount}',
              ),
              const Divider(height: UrbinkSpacing.xl),
              _StatRow(
                emoji: '📍',
                label: l10n.stat_distance,
                value: distanceLabel,
              ),
              const Divider(height: UrbinkSpacing.xl),
              _StatRow(
                emoji: '⏱️',
                label: l10n.stat_duration,
                value: durationLabel,
              ),
              const Divider(height: UrbinkSpacing.xl),
              _StatRow(
                emoji: session.mode.emoji,
                label: l10n.stat_mode,
                value: session.mode.label,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UrbinkColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      UrbinkSpacing.minTapTarget,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.btn_back_to_map),
                ),
              ),
              const SizedBox(height: UrbinkSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: UrbinkSpacing.md),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: UrbinkColors.onSurface,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: UrbinkColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
