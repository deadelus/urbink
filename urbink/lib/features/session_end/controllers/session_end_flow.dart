import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/core/router/app_router.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/badge_celebration.dart';
import 'package:urbink/features/session_end/widgets/session_summary_sheet.dart';
import 'package:urbink/features/sessions/models/session_data.dart';

/// Orchestre la séquence complète de fin de sortie :
///
/// 1. [SessionSummarySheet] en bottom sheet modale
/// 2. [BadgeCelebration] plein-écran pour chaque badge (enchaînés)
/// 3. Retour à la carte via GoRouter
abstract final class SessionEndFlow {
  /// Lance la séquence depuis un [BuildContext] valide.
  ///
  /// [session] — données de la sortie terminée
  /// [badges]  — liste des badges débloqués (peut être vide)
  static Future<void> show({
    required BuildContext context,
    required SessionData session,
    required List<BadgeUnlock> badges,
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
            // "Super !" → célébrer si des badges existent
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

    // ── 2. Célébrations enchaînées ───────────────────────────────────────
    if (celebrate && badges.isNotEmpty) {
      for (int i = 0; i < badges.length; i++) {
        if (!context.mounted) break;

        bool skipAll = false;
        await showGeneralDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (ctx, _, _) => BadgeCelebration(
            badge: badges[i],
            currentIndex: i + 1,
            total: badges.length,
            onDone: () => Navigator.of(ctx).pop(),
            onSkipAll: () {
              skipAll = true;
              Navigator.of(ctx).pop();
            },
          ),
          transitionDuration: Duration.zero,
        );

        if (skipAll) break;

        // 200ms entre deux célébrations
        if (i < badges.length - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }

    // ── 3. Retour carte ────────────────────────────────────────────────────
    if (context.mounted) context.go(AppRoutes.map);
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
        // Barrière cliquable (ferme le sheet)
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withValues(alpha: 0.60)),
          ),
        ),
        // Sheet positionné en bas
        Align(alignment: Alignment.bottomCenter, child: child),
      ],
    );
  }
}
