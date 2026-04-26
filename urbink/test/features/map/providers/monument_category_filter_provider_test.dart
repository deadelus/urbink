import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/features/map/providers/active_filters_provider.dart';
import 'package:urbink/features/map/providers/monument_category_filter_provider.dart';

Monument _m({String category = '', String subtype = ''}) => Monument(
      id: 'test',
      name: 'Test',
      category: category,
      categoryIcon: '📍',
      subtype: subtype,
      position: const LatLng(48.85, 2.35),
    );

ProviderContainer _makeContainer({Set<String> activeFilters = const {'monuments'}}) {
  return ProviderContainer(
    overrides: [
      activeFiltersProvider.overrideWith((ref) => activeFilters),
    ],
  );
}

void main() {
  group('monumentVisibilityPredicateProvider', () {
    test('aucun filtre actif → false pour tout monument', () {
      final c = _makeContainer(activeFilters: const {});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Palais & Monuments emblématiques')), isFalse);
      expect(pred(_m(category: 'Musées & Bibliothèques')), isFalse);
    });

    test('filtre "monuments" → catégories patrimoniales larges visibles', () {
      final c = _makeContainer(activeFilters: {'monuments'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Palais & Monuments emblématiques')), isTrue);
      expect(pred(_m(category: 'Statues & sculptures urbaines')), isTrue);
      expect(pred(_m(category: 'Édifices religieux')), isTrue);
      expect(pred(_m(category: 'Petit patrimoine urbain')), isTrue);
    });

    test('filtre "monuments" → Musées & Architecture ABSENTS', () {
      final c = _makeContainer(activeFilters: {'monuments'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Musées & Bibliothèques')), isFalse);
      expect(pred(_m(category: 'Architecture résidentielle')), isFalse);
    });

    test('filtre "statues" sans "monuments" → statues seulement', () {
      final c = _makeContainer(activeFilters: {'statues'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Statues & sculptures urbaines')), isTrue);
      expect(pred(_m(category: 'Palais & Monuments emblématiques')), isFalse);
    });

    test('filtre "fontaines" → sous-type Fontaine visible, autres non', () {
      final c = _makeContainer(activeFilters: {'fontaines'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Petit patrimoine urbain', subtype: 'Fontaine')), isTrue);
      expect(pred(_m(category: 'Petit patrimoine urbain', subtype: 'Kiosque')), isFalse);
    });

    test('filtre "ponts" → Pont et Passerelle visibles', () {
      final c = _makeContainer(activeFilters: {'ponts'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(subtype: 'Pont')), isTrue);
      expect(pred(_m(subtype: 'Passerelle')), isTrue);
      expect(pred(_m(subtype: 'Aqueduc')), isTrue);
      expect(pred(_m(subtype: 'Fontaine')), isFalse);
    });

    test('filtre "eglises" → Édifices religieux visible', () {
      final c = _makeContainer(activeFilters: {'eglises'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Édifices religieux')), isTrue);
      expect(pred(_m(category: 'Palais & Monuments emblématiques')), isFalse);
    });

    test('filtre "metro_histo" → Station de métro visible', () {
      final c = _makeContainer(activeFilters: {'metro_histo'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(subtype: 'Station de métro')), isTrue);
      expect(pred(_m(subtype: 'Fontaine')), isFalse);
    });

    test('filtre "musees" → Musées & Bibliothèques visible', () {
      final c = _makeContainer(activeFilters: {'musees'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Musées & Bibliothèques')), isTrue);
      expect(pred(_m(category: 'Palais & Monuments emblématiques')), isFalse);
    });

    test('filtre "cinemas" → Théâtres & cinémas visible', () {
      final c = _makeContainer(activeFilters: {'cinemas'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Théâtres, cinémas & lieux culturels')), isTrue);
    });

    test('filtre "jardins" → Parcs & cimetières visible', () {
      final c = _makeContainer(activeFilters: {'jardins'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Parcs, jardins & cimetières funéraires')), isTrue);
    });

    test('filtres combinés "statues" + "musees" → union', () {
      final c = _makeContainer(activeFilters: {'statues', 'musees'});
      addTearDown(c.dispose);
      final pred = c.read(monumentVisibilityPredicateProvider);
      expect(pred(_m(category: 'Statues & sculptures urbaines')), isTrue);
      expect(pred(_m(category: 'Musées & Bibliothèques')), isTrue);
      expect(pred(_m(category: 'Palais & Monuments emblématiques')), isFalse);
    });
  });

  group('hasActiveMonumentFiltersProvider', () {
    test('filtres vides → false', () {
      final c = _makeContainer(activeFilters: const {});
      addTearDown(c.dispose);
      expect(c.read(hasActiveMonumentFiltersProvider), isFalse);
    });

    test('filtre "monuments" → true', () {
      final c = _makeContainer(activeFilters: {'monuments'});
      addTearDown(c.dispose);
      expect(c.read(hasActiveMonumentFiltersProvider), isTrue);
    });

    test('filtre "fontaines" → true', () {
      final c = _makeContainer(activeFilters: {'fontaines'});
      addTearDown(c.dispose);
      expect(c.read(hasActiveMonumentFiltersProvider), isTrue);
    });

    test('filtre non-monument ("velos") → false', () {
      final c = _makeContainer(activeFilters: {'velos'});
      addTearDown(c.dispose);
      expect(c.read(hasActiveMonumentFiltersProvider), isFalse);
    });
  });
}
