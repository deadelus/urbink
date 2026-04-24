import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/stat_grid_card.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/typography.dart';

/// Bottom sheet modale récapitulant une sortie terminée.
///
/// Affiché via [showModalBottomSheet] avec [isScrollControlled: true].
/// Appelle [onClose] quand l'utilisateur tape "Super !" ou fait swipe-down.
/// Appelle [onCelebrate] avec les badges quand il tape le bandeau badges.
class SessionSummarySheet extends StatelessWidget {
  final SessionData session;
  final List<BadgeUnlock> newBadges;
  final VoidCallback onClose;
  final ValueChanged<List<BadgeUnlock>> onCelebrate;

  const SessionSummarySheet({
    super.key,
    required this.session,
    required this.newBadges,
    required this.onClose,
    required this.onCelebrate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);

    // Format durée MM:SS ou H:MM:SS
    final duration = Duration(seconds: session.secs);
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final durationLabel = h > 0 ? '$h:$m:$s' : '$m:$s';

    final distanceLabel = session.km >= 1.0
        ? session.km.toStringAsFixed(1)
        : (session.km * 1000).toStringAsFixed(0);
    final distanceUnit = session.km >= 1.0 ? l10n.sum_km : 'm';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mq.size.height * 0.85,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: UrbinkColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: UrbinkColors.sheetDragPill,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: mq.padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero
                    _Hero(l10n: l10n),
                    const SizedBox(height: 24),

                    // Grille stats 2×2
                    Semantics(
                      label: '${session.streets} ${l10n.sum_streets}, '
                          '$distanceLabel $distanceUnit, '
                          '${l10n.sum_duration} $durationLabel, '
                          '${newBadges.length} ${l10n.sum_new_badges}',
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatGridCard(
                            emoji: '🗺️',
                            value: '${session.streets}',
                            unit: l10n.sum_streets,
                          ),
                          StatGridCard(
                            emoji: '📏',
                            value: distanceLabel,
                            unit: distanceUnit,
                          ),
                          StatGridCard(
                            emoji: '⏱',
                            value: durationLabel,
                            unit: l10n.sum_duration,
                          ),
                          StatGridCard(
                            emoji: '🏆',
                            value: '${newBadges.length}',
                            unit: l10n.sum_new_badges,
                          ),
                        ],
                      ),
                    ),

                    // Bandeau badges (si ≥ 1)
                    if (newBadges.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _BadgesBanner(badges: newBadges, onTap: () => onCelebrate(newBadges)),
                    ],

                    const SizedBox(height: 20),

                    // Actions
                    _ActionsRow(
                      l10n: l10n,
                      session: session,
                      onClose: onClose,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            l10n.sum_title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: UrbinkTypography.displayFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: UrbinkColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.sum_sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: UrbinkTypography.bodyFamily,
              fontSize: 13,
              color: UrbinkColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BadgesBanner extends StatelessWidget {
  const _BadgesBanner({required this.badges, required this.onTap});
  final List<BadgeUnlock> badges;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final names = badges.map((b) => b.name).join(' · ');
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.sum_badges_unlocked(badges.length),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: UrbinkColors.accent.withValues(alpha: 0.10),
            border: Border.all(
              color: UrbinkColors.accent.withValues(alpha: 0.22),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sum_badges_unlocked(badges.length),
                      style: const TextStyle(
                        fontFamily: UrbinkTypography.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: UrbinkColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      names,
                      style: const TextStyle(
                        fontFamily: UrbinkTypography.bodyFamily,
                        fontSize: 11,
                        color: UrbinkColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded,
                  color: UrbinkColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.l10n,
    required this.session,
    required this.onClose,
  });

  final AppLocalizations l10n;
  final SessionData session;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () => _share(session, l10n),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: Text(l10n.sum_share),
            style: OutlinedButton.styleFrom(
              foregroundColor: UrbinkColors.primary,
              side: const BorderSide(color: UrbinkColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: UrbinkColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(0, 52),
            ),
            child: Text(
              l10n.sum_done,
              style: const TextStyle(
                fontFamily: UrbinkTypography.bodyFamily,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _share(SessionData s, AppLocalizations l10n) async {
    final km = s.km.toStringAsFixed(1);
    await Share.share(
      'Je viens de découvrir ${s.streets} rues ($km km) avec Urbink ! 🗺️',
    );
  }
}
