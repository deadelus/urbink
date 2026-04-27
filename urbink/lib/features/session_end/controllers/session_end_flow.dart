import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/session_summary_sheet.dart';
import 'package:urbink/features/sessions/models/session_data.dart';

/// Orchestre la séquence complète de fin de sortie :
///
/// 1. [SessionSummarySheet] en bottom sheet modale
/// 2. Push des badges dans [celebrationQueueProvider] (affichage via [CelebrationQueueListener])
/// 3. Retour à la carte via GoRouter
abstract final class SessionEndFlow {
  /// Lance la séquence depuis un [BuildContext] + [WidgetRef] valides.
  ///
  /// [session] — données de la sortie terminée
  /// [badges]  — liste des badges débloqués (peut être vide)
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required SessionData session,
    required List<BadgeUnlock> badges,
    VoidCallback? onNavigate,
  }) async {
    // ── 1. Summary sheet ────────────────────────────────────────────────────
    bool celebrate = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => _BlurredScrim(
        child: SessionSummarySheet(
          session: session,
          newBadges: badges,
          onClose: () {
            celebrate = badges.isNotEmpty;
            Navigator.of(ctx).pop();
          },
          onCelebrate: (_) {
            celebrate = true;
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );

    if (!context.mounted) return;

    // ── 2. Push badges dans la queue ────────────────────────────────────────
    if (celebrate && badges.isNotEmpty) {
      for (final badge in badges) {
        ref.read(celebrationQueueProvider.notifier).push(
          CelebrationEvent(
            id: 'badge-${badge.id}',
            mode: CelebrationMode.badge,
            title: badge.name,
            subtitle: badge.description,
            iconEmoji: badge.icon,
          ),
        );
      }
    }

    // ── 3. Retour carte ────────────────────────────────────────────────────
    if (context.mounted) {
      if (onNavigate != null) {
        onNavigate();
      } else {
        context.go(AppRoutes.map);
      }
    }
  }
}

// ---------------------------------------------------------------------------

/// Scrim semi-transparent avec BackdropFilter blur 8 — enveloppe le sheet.
class _BlurredScrim extends StatelessWidget {
  const _BlurredScrim({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withValues(alpha: 0.60)),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: child),
      ],
    );
  }
}
