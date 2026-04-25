import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/providers/active_filters_provider.dart';
import 'package:urbink/features/map/providers/monument_category_filter_provider.dart';

ProviderContainer _makeContainer({Set<String> activeFilters = const {'monuments'}}) {
  return ProviderContainer(
    overrides: [
      activeFiltersProvider.overrideWith((ref) => activeFilters),
    ],
  );
}

void main() {
  group('visibleMonumentCategoriesProvider', () {
    test('filtre "monuments" actif → Palais, Statues, Édifices, etc. visibles', () {
      final c = _makeContainer(activeFilters: {'monuments'});
      addTearDown(c.dispose);

      final visible = c.read(visibleMonumentCategoriesProvider);
      expect(visible, contains('Palais & Monuments emblématiques'));
      expect(visible, contains('Statues & sculptures urbaines'));
      expect(visible, contains('Édifices religieux'));
      expect(visible, contains('Petit patrimoine urbain'));
    });

    test('filtre "monuments" actif → bâtiments et hôtels ABSENTS', () {
      final c = _makeContainer(activeFilters: {'monuments'});
      addTearDown(c.dispose);

      final visible = c.read(visibleMonumentCategoriesProvider);
      expect(visible, isNot(contains('Architecture résidentielle')));
      expect(visible, isNot(contains('Hôtels particuliers')));
    });

    test('filtre "musees" actif → Musées & Bibliothèques visibles', () {
      final c = _makeContainer(activeFilters: {'musees'});
      addTearDown(c.dispose);

      final visible = c.read(visibleMonumentCategoriesProvider);
      expect(visible, contains('Musées & Bibliothèques'));
      expect(visible, isNot(contains('Palais & Monuments emblématiques')));
    });

    test('filtres "cafes" + "restaurants" → Cafés historiques visibles', () {
      final c = _makeContainer(activeFilters: {'cafes'});
      addTearDown(c.dispose);

      final visible = c.read(visibleMonumentCategoriesProvider);
      expect(visible, contains('Cafés, restaurants & commerces historiques'));
    });

    test('filtres "theatres" ou "cinemas" → Théâtres & cinémas visibles', () {
      final c = _makeContainer(activeFilters: {'cinemas'});
      addTearDown(c.dispose);

      expect(
        c.read(visibleMonumentCategoriesProvider),
        contains('Théâtres, cinémas & lieux culturels'),
      );
    });

    test('filtres "parcs" ou "jardins" → Parcs visibles', () {
      final c = _makeContainer(activeFilters: {'jardins'});
      addTearDown(c.dispose);

      expect(
        c.read(visibleMonumentCategoriesProvider),
        contains('Parcs, jardins & cimetières funéraires'),
      );
    });

    test('aucun filtre actif → aucune catégorie visible', () {
      final c = _makeContainer(activeFilters: const {});
      addTearDown(c.dispose);

      expect(c.read(visibleMonumentCategoriesProvider), isEmpty);
    });

    test('tous les filtres → toutes les catégories mappées visibles', () {
      final c = _makeContainer(
        activeFilters: {'monuments', 'musees', 'theatres', 'cafes', 'parcs'},
      );
      addTearDown(c.dispose);

      final visible = c.read(visibleMonumentCategoriesProvider);
      expect(visible.length, 10); // toutes les catégories mappées
    });
  });
}
