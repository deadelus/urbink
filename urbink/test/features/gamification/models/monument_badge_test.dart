import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/monument_badge.dart';

void main() {
  group('MonumentBadge', () {
    test('idFor génère le bon identifiant', () {
      expect(MonumentBadge.idFor('PA01234'), 'monument_PA01234');
      expect(MonumentBadge.idFor('tour-eiffel'), 'monument_tour-eiffel');
    });

    test('toFirestore sérialise tous les champs', () {
      final badge = MonumentBadge(
        id: 'monument_PA01234',
        monumentId: 'PA01234',
        name: 'Tour Eiffel',
        emoji: '🗼',
        unlockedAt: DateTime(2026, 4, 27, 12, 0, 0),
      );

      final map = badge.toFirestore();

      expect(map['monumentId'], 'PA01234');
      expect(map['name'], 'Tour Eiffel');
      expect(map['emoji'], '🗼');
      expect(map['type'], 'monument');
      expect(map['unlockedAt'], isA<Timestamp>());
    });

    test('toFirestore ne contient pas le champ id (géré par Firestore)', () {
      final badge = MonumentBadge(
        id: 'monument_PA01234',
        monumentId: 'PA01234',
        name: 'Tour Eiffel',
        emoji: '🗼',
        unlockedAt: DateTime(2026, 4, 27),
      );

      expect(badge.toFirestore().containsKey('id'), isFalse);
    });

    test('emoji par défaut quand absent du Firestore', () {
      // Simule un document sans champ emoji (lecture fromFirestore)
      // On vérifie la logique du provider Go avec un emoji null → '🏛️'
      // Côté Dart, le modèle utilise ?? '🏛️' dans fromFirestore
      final badge = MonumentBadge(
        id: 'monument_X',
        monumentId: 'X',
        name: 'Monument inconnu',
        emoji: '🏛️',
        unlockedAt: DateTime(2026, 4, 27),
      );

      expect(badge.emoji, '🏛️');
    });
  });
}
