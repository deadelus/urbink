import 'package:flutter_riverpod/flutter_riverpod.dart';

/// États possibles de la session de marche.
enum SessionState {
  /// Aucune session en cours — bouton Démarrer Vert Sauge ▶ visible
  idle,

  /// Session GPS en cours — bouton Démarrer Ocre ⏸ visible, bouton Arrêter visible
  active,

  /// Session en pause — bouton Démarrer Vert Sauge ▶ visible, bouton Arrêter toujours visible
  paused,
}

/// État de la session de marche en cours.
///
/// Utilisé par [UrbinkBottomNav] pour basculer l'icône Démarrer ▶ ↔ ⏸
/// et par le scaffold pour afficher le bouton Arrêter top-right.
///
/// Valeurs :
///   [SessionState.idle]   → aucune session (bouton Démarrer Vert Sauge ▶)
///   [SessionState.active] → session en cours (bouton Démarrer Ocre ⏸, bouton Arrêter visible)
///   [SessionState.paused] → session en pause (bouton Démarrer Vert Sauge ▶, bouton Arrêter visible)
///
/// Note : la gestion complète de la session GPS (tracking, snap to road, Firestore)
/// sera implémentée dans les stories Epic 2. Ce provider gère uniquement l'état UI.
final sessionStateProvider = StateProvider<SessionState>((ref) => SessionState.idle);
