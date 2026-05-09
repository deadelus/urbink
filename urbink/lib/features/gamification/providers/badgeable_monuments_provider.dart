import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/features/map/providers/monuments_provider.dart';

/// Catégories de monuments affichées dans le BadgeGrid.
/// Filtre les monuments les plus emblématiques / gamifiables.
const _kBadgeableCategories = {
  'Palais & Monuments emblématiques',
  'Musées & Bibliothèques',
};

/// Liste des monuments affichables dans le BadgeGrid — sous-ensemble gamifiable.
///
/// Filtre [monumentsProvider] aux catégories emblématiques (~197 monuments)
/// pour garder une grille lisible sans afficher les 1 999 entrées.
final badgeableMonumentsProvider = FutureProvider<List<Monument>>((ref) async {
  final all = await ref.watch(monumentsProvider.future);
  return all
      .where((m) => _kBadgeableCategories.contains(m.category))
      .toList();
});
