import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/badges/data/collection_model.dart';

void main() {
  group('CollectionStats', () {
    MonumentCollection makeCollection(List<bool> lockedStates) {
      return MonumentCollection(
        id: 'test',
        name: 'Test',
        subtitle: 'Sub',
        icon: '⭐',
        color: Colors.amber,
        monuments: [
          for (int i = 0; i < lockedStates.length; i++)
            CollectionMonument(
              id: 'mon-$i',
              emoji: '🏛️',
              name: 'Monument $i',
              locked: lockedStates[i],
            ),
        ],
      );
    }

    test('pct = 67 quand 4/6 débloqués', () {
      final col = makeCollection([false, false, false, false, true, true]);
      final stats = col.stats;
      expect(stats.unlocked, 4);
      expect(stats.total, 6);
      expect(stats.pct, 67);
    });

    test('pct = 100 quand tous débloqués', () {
      final col = makeCollection([false, false, false]);
      expect(col.stats.pct, 100);
    });

    test('pct = 0 quand tous verrouillés', () {
      final col = makeCollection([true, true, true]);
      expect(col.stats.pct, 0);
    });

    test('pct = 0 quand liste vide', () {
      const col = MonumentCollection(
        id: 'empty',
        name: 'Empty',
        subtitle: '',
        icon: '⭐',
        color: Colors.amber,
        monuments: [],
      );
      expect(col.stats.pct, 0);
    });

    test('withUnlockedIds applique le bon état locked', () {
      final col = makeCollection([true, true, true]);
      final updated = col.withUnlockedIds({'mon-0', 'mon-2'});
      expect(updated.monuments[0].locked, false);
      expect(updated.monuments[1].locked, true);
      expect(updated.monuments[2].locked, false);
    });
  });
}
