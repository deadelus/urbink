import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/badges/state/badges_provider.dart';
import 'package:urbink/features/profile/data/explorer_rank.dart';

// ---------------------------------------------------------------------------
// explorerXpProvider — nombre total de monuments débloqués (= XP global)
// ---------------------------------------------------------------------------

final explorerXpProvider = Provider<int>((ref) {
  return ref.watch(badgesStatsProvider).monumentsUnlocked;
});

// ---------------------------------------------------------------------------
// explorerRankProvider — rang actuel dérivé du XP
// ---------------------------------------------------------------------------

final explorerRankProvider = Provider<ExplorerRank>((ref) {
  return rankForXp(ref.watch(explorerXpProvider));
});
