import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État global des couches carte (monuments, quartiers, photos/pins).
///
/// Remplace le `Map<String,bool>` local de _SelectModeBodyState pour que les
/// overlays carte puissent observer les toggles sans passer par le widget tree.
final mapLayersProvider = StateProvider<Map<String, bool>>((ref) {
  return const {'monuments': true, 'quartiers': false, 'photos': false};
});
