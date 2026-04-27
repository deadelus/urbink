import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/quartier_badge.dart';

void main() {
  group('QuartierBadge', () {
    test('idFor génère l\'identifiant correct', () {
      expect(QuartierBadge.idFor('arrond_1'), 'quartier_arrond_1');
      expect(QuartierBadge.idFor('arrond_20'), 'quartier_arrond_20');
    });

    test('toFirestore sérialise tous les champs', () {
      final badge = QuartierBadge(
        id: 'quartier_arrond_1',
        quartierId: 'arrond_1',
        name: '1er',
        secretLocal: 'Secret test',
        unlockedAt: DateTime(2026, 4, 27, 12, 0, 0),
      );

      final map = badge.toFirestore();

      expect(map['quartierId'], 'arrond_1');
      expect(map['name'], '1er');
      expect(map['secretLocal'], 'Secret test');
      expect(map['unlockedAt'], isNotNull);
    });

    test('toFirestore ne contient pas le champ id (géré par le doc Firestore)', () {
      final badge = QuartierBadge(
        id: 'quartier_arrond_1',
        quartierId: 'arrond_1',
        name: '1er',
        secretLocal: 'Secret test',
        unlockedAt: DateTime(2026, 4, 27),
      );

      final map = badge.toFirestore();
      expect(map.containsKey('id'), isFalse);
    });
  });
}
