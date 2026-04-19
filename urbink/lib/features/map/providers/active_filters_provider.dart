import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ensemble des IDs de filtres POI actifs — partagé entre la carte et l'itinéraire.
final activeFiltersProvider = StateProvider<Set<String>>(
  (ref) => const {'monuments'},
);
