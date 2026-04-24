import 'package:urbink/features/session_end/models/badge_unlock.dart';

/// Détecte les badges débloqués à la fin d'une sortie.
///
/// La logique métier complète est hors scope (Story 3.2.x) — cette
/// implémentation expose l'interface attendue et retourne une liste vide.
/// Remplacer [detectUnlocks] avec la vraie logique dès que disponible.
abstract final class BadgeDetector {
  /// Calcule les badges débloqués en comparant les rues explorées
  /// [exploredStreets] aux badges déjà acquis [currentBadgeIds].
  ///
  /// Retourne une liste ordonnée des [BadgeUnlock] nouvellement acquis.
  static List<BadgeUnlock> detectUnlocks({
    required Set<String> exploredStreets,
    required List<String> currentBadgeIds,
  }) {
    // TODO(story-3.x): implémenter la vraie détection via Hive/repository
    return [];
  }
}
