import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/features/map/providers/active_filters_provider.dart';

const _kBroadMonumentCategories = <String>{
  'Palais & Monuments emblématiques',
  'Petit patrimoine urbain',
  'Statues & sculptures urbaines',
  'Édifices religieux',
  'Transports & infrastructures',
  'Patrimoine industriel & artisanat',
};

const _kBridgeSubtypes = <String>{'Pont', 'Passerelle', 'Aqueduc'};

const _kAllMonumentFilterIds = <String>{
  'monuments', 'statues', 'fontaines', 'ponts', 'eglises', 'palais', 'metro_histo',
  'musees', 'theatres', 'cinemas', 'cafes', 'restaurants', 'parcs', 'jardins',
};

/// Vrai si au moins un filtre affectant les monuments est actif.
final hasActiveMonumentFiltersProvider = Provider<bool>((ref) {
  final activeFilters = ref.watch(activeFiltersProvider);
  return activeFilters.any(_kAllMonumentFilterIds.contains);
});

/// Prédicat de visibilité dérivé des filtres actifs.
///
/// Combinaison catégorie + sous-type :
///   - 'monuments'    → toutes les grandes catégories patrimoniales
///   - 'statues'      → Statues & sculptures urbaines
///   - 'fontaines'    → sous-type Fontaine
///   - 'ponts'        → sous-types Pont / Passerelle / Aqueduc
///   - 'eglises'      → Édifices religieux
///   - 'palais'       → Palais & Monuments emblématiques
///   - 'metro_histo'  → sous-type Station de métro
///   - 'musees'       → Musées & Bibliothèques
///   - 'theatres'/'cinemas'     → Théâtres, cinémas & lieux culturels
///   - 'cafes'/'restaurants'    → Cafés, restaurants & commerces historiques
///   - 'parcs'/'jardins'        → Parcs, jardins & cimetières funéraires
final monumentVisibilityPredicateProvider = Provider<bool Function(Monument)>((ref) {
  final f = ref.watch(activeFiltersProvider);

  return (Monument m) {
    if (f.contains('monuments') && _kBroadMonumentCategories.contains(m.category)) return true;
    if (f.contains('statues') && m.category == 'Statues & sculptures urbaines') return true;
    if (f.contains('fontaines') && m.subtype == 'Fontaine') return true;
    if (f.contains('ponts') && _kBridgeSubtypes.contains(m.subtype)) return true;
    if (f.contains('eglises') && m.category == 'Édifices religieux') return true;
    if (f.contains('palais') && m.category == 'Palais & Monuments emblématiques') return true;
    if (f.contains('metro_histo') && m.subtype == 'Station de métro') return true;
    if (f.contains('musees') && m.category == 'Musées & Bibliothèques') return true;
    if ((f.contains('theatres') || f.contains('cinemas')) && m.category == 'Théâtres, cinémas & lieux culturels') return true;
    if ((f.contains('cafes') || f.contains('restaurants')) && m.category == 'Cafés, restaurants & commerces historiques') return true;
    if ((f.contains('parcs') || f.contains('jardins')) && m.category == 'Parcs, jardins & cimetières funéraires') return true;
    return false;
  };
});
