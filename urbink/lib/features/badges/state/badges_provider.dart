import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/data/collections_repository.dart';
import 'package:urbink/features/gamification/providers/monument_badges_provider.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';

// ---------------------------------------------------------------------------
// collectionsProvider — collections avec état locked/unlocked appliqué
// ---------------------------------------------------------------------------

final collectionsProvider = Provider<List<MonumentCollection>>((ref) {
  final unlockedIds = ref.watch(monumentBadgeIdsProvider);
  return CollectionsRepository.forCity(
    cityId: 'paris',
    unlockedMonumentIds: unlockedIds,
  );
});

// ---------------------------------------------------------------------------
// badgesStatsProvider — métriques agrégées pour le stats banner
// ---------------------------------------------------------------------------

class BadgesStats {
  final int monumentsUnlocked;
  final int collectionsComplete;
  final int quartiersComplete;

  const BadgesStats({
    required this.monumentsUnlocked,
    required this.collectionsComplete,
    required this.quartiersComplete,
  });
}

final badgesStatsProvider = Provider<BadgesStats>((ref) {
  final collections = ref.watch(collectionsProvider);
  final unlockedIds = ref.watch(monumentBadgeIdsProvider);
  final progressionAsync = ref.watch(quartiersProgressionProvider);

  final monumentsUnlocked = CollectionsRepository.countDistinctUnlocked(
    cityId: 'paris',
    unlockedMonumentIds: unlockedIds,
  );

  final collectionsComplete =
      collections.where((c) => c.stats.pct == 100).length;

  final quartiersComplete = progressionAsync.valueOrNull
          ?.where((q) => q.completionPercent >= 100)
          .length ??
      0;

  return BadgesStats(
    monumentsUnlocked: monumentsUnlocked,
    collectionsComplete: collectionsComplete,
    quartiersComplete: quartiersComplete,
  );
});
