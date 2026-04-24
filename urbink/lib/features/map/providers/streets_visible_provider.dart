import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggle d'affichage des rues explorées sur la carte (FR10b).
///
/// `true`  → rues colorées visibles.
/// `false` → overlay masqué côté UI (état par défaut) — le tracking passif continue en arrière-plan.
///
/// Contrôlé par le pill Zones bas-gauche dans [MapScreen] via [ZonesTogglePill].
final streetsVisibleProvider = StateProvider<bool>((ref) => false);
