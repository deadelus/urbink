import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catégories de monuments masquées sur la carte.
///
/// Architecture résidentielle (762) et Hôtels particuliers (363) sont cachés
/// par défaut car trop nombreux et peu informatifs à l'échelle utilisateur.
/// L'UI de gestion des filtres catégories viendra dans une story dédiée.
const kDefaultHiddenMonumentCategories = {
  'Architecture résidentielle',
  'Hôtels particuliers',
};

final monumentHiddenCategoriesProvider = StateProvider<Set<String>>((ref) {
  return kDefaultHiddenMonumentCategories;
});
