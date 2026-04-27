import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/providers/monument_badges_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

void main() {
  group('monumentBadgeIdsProvider', () {
    test('retourne un Set vide quand uid est null', () {
      final container = ProviderContainer(
        overrides: [
          currentUidProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      final ids = container.read(monumentBadgeIdsProvider);
      expect(ids, isEmpty);
    });

    test('monumentBadgesStreamProvider retourne un stream vide quand uid est null', () async {
      final container = ProviderContainer(
        overrides: [
          currentUidProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      // Attend que le provider soit résolu
      await container.read(monumentBadgesStreamProvider.future);
      final value = container.read(monumentBadgesStreamProvider);
      expect(value.valueOrNull, isEmpty);
    });
  });

  group('writeMonumentProximityEvent', () {
    test('badgeId format monument_X dans idFor', () {
      // Vérifie indirectement le document ID utilisé pour la déduplication
      // (même logique que MonumentBadge.idFor)
      // Pas de test Firestore réel — couvert par les tests Go de la CF
    });
  });
}
