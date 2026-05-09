import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/data/paris_collections.dart';

// ---------------------------------------------------------------------------
// CollectionsRepository
// Retourne les collections avec l'état locked/unlocked appliqué.
// ---------------------------------------------------------------------------

abstract final class CollectionsRepository {
  /// Retourne les collections de la ville avec état locked dérivé de
  /// [unlockedMonumentIds] — IDs des monuments débloqués par l'utilisateur.
  static List<MonumentCollection> forCity({
    required String cityId,
    required Set<String> unlockedMonumentIds,
  }) {
    final raw = _rawCollections(cityId);
    return raw
        .map((col) => col.withUnlockedIds(unlockedMonumentIds))
        .toList();
  }

  /// Nombre total de monuments distincts débloqués dans toutes les collections.
  static int countDistinctUnlocked({
    required String cityId,
    required Set<String> unlockedMonumentIds,
  }) {
    final allIds = _rawCollections(cityId)
        .expand((c) => c.monuments.map((m) => m.id))
        .toSet();
    return allIds.intersection(unlockedMonumentIds).length;
  }

  static List<MonumentCollection> _rawCollections(String cityId) {
    // Seul Paris est seedé pour l'instant.
    return kParisCollections;
  }
}
