import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État de la session de marche en cours.
///
/// Utilisé par [UrbinkBottomNav] pour basculer l'icône Démarrer ▶ ↔ ⏸
/// et par le scaffold pour afficher le bouton Arrêter top-right.
///
/// Valeurs :
///   false → aucune session active (état initial, bouton Démarrer Ocre ▶)
///   true  → session en cours (bouton Démarrer Vert Sauge ⏸, bouton Arrêter visible)
///
/// Note : la gestion complète de la session GPS (tracking, snap to road, Firestore)
/// sera implémentée dans les stories Epic 2. Ce provider gère uniquement l'état UI.
final sessionActiveProvider = StateProvider<bool>((ref) => false);
