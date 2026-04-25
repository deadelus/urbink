import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/active_filters_provider.dart';

/// Mapping catégorie Mérimée → IDs de filtres POI ([activeFiltersProvider]).
///
/// Une catégorie est affichée si au moins un de ses filter IDs est actif.
/// Les catégories absentes (Architecture résidentielle, Hôtels particuliers)
/// ne sont jamais affichées — trop nombreuses et peu informatives.
const _kCategoryToFilterIds = <String, Set<String>>{
  'Palais & Monuments emblématiques':       {'monuments'},
  'Petit patrimoine urbain':                {'monuments'},
  'Statues & sculptures urbaines':          {'monuments'},
  'Édifices religieux':                     {'monuments'},
  'Transports & infrastructures':           {'monuments'},
  'Patrimoine industriel & artisanat':      {'monuments'},
  'Musées & Bibliothèques':                 {'musees'},
  'Théâtres, cinémas & lieux culturels':    {'theatres', 'cinemas'},
  'Cafés, restaurants & commerces historiques': {'cafes', 'restaurants'},
  'Parcs, jardins & cimetières funéraires': {'parcs', 'jardins'},
};

/// Ensemble des catégories Mérimée visibles, dérivé des filtres actifs.
///
/// Ex : filtres actifs = {'monuments', 'musees'}
///   → visible = {Palais, Petit patrimoine, Statues, Édifices, ..., Musées}
final visibleMonumentCategoriesProvider = Provider<Set<String>>((ref) {
  final activeFilters = ref.watch(activeFiltersProvider);
  return {
    for (final entry in _kCategoryToFilterIds.entries)
      if (entry.value.any((id) => activeFilters.contains(id))) entry.key,
  };
});
