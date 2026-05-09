import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/data/paris_collections.dart';

void main() {
  group('MonumentCollection.transportModes', () {
    test('toutes les collections ont au moins un mode de transport', () {
      for (final col in kParisCollections) {
        expect(col.transportModes, isNotEmpty,
            reason: '${col.id} doit avoir au moins un mode');
      }
    });

    test('les modes sont parmi les valeurs autorisées', () {
      const allowed = {'foot', 'bike', 'all'};
      for (final col in kParisCollections) {
        for (final mode in col.transportModes) {
          expect(allowed.contains(mode), isTrue,
              reason: 'Mode "$mode" dans ${col.id} est invalide');
        }
      }
    });

    test('withUnlockedIds préserve les transportModes', () {
      const col = MonumentCollection(
        id: 'test',
        name: 'Test',
        subtitle: 'Sub',
        icon: '⭐',
        color: Colors.amber,
        monuments: [
          CollectionMonument(id: 'a', emoji: '🏛️', name: 'A'),
          CollectionMonument(id: 'b', emoji: '🏛️', name: 'B'),
        ],
        transportModes: ['foot', 'bike'],
      );
      final updated = col.withUnlockedIds({'a'});
      expect(updated.transportModes, equals(['foot', 'bike']));
      expect(updated.monuments.first.locked, isFalse);
      expect(updated.monuments.last.locked, isTrue);
    });

    test('transportModes par défaut est [foot]', () {
      const col = MonumentCollection(
        id: 'default',
        name: 'Default',
        subtitle: 'Sub',
        icon: '⭐',
        color: Colors.amber,
        monuments: [],
      );
      expect(col.transportModes, equals(['foot']));
    });
  });

  group('paris_collections data', () {
    test('12 collections sont définies', () {
      expect(kParisCollections.length, 12);
    });

    test('chaque collection a un id unique', () {
      final ids = kParisCollections.map((c) => c.id).toSet();
      expect(ids.length, kParisCollections.length);
    });

    test('collection indispensables a le mode vélo', () {
      final col = kParisCollections.firstWhere((c) => c.id == 'indispensables');
      expect(col.transportModes, contains('bike'));
    });

    test('collection tresors-caches est uniquement à pied', () {
      final col = kParisCollections.firstWhere((c) => c.id == 'tresors-caches');
      expect(col.transportModes, equals(['foot']));
    });
  });
}
