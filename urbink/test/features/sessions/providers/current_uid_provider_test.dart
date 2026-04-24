import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/providers/aggregation_provider.dart';
import 'package:urbink/features/map/providers/historical_streets_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

void main() {
  group('currentUidProvider', () {
    test('retourne null quand non authentifié', () {
      final container = ProviderContainer(
        overrides: [currentUidProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUidProvider), isNull);
    });

    test('retourne l\'UID quand authentifié', () {
      const uid = 'anon-uid-abc123';
      final container = ProviderContainer(
        overrides: [currentUidProvider.overrideWith((ref) => uid)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUidProvider), equals(uid));
    });
  });

  group('aggregationProvider — comportement si uid null', () {
    test('retourne Set vide sans erreur', () async {
      final container = ProviderContainer(
        overrides: [currentUidProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(aggregationProvider.future);
      expect(result, isEmpty);
    });
  });

  group('historicalStreetsProvider — comportement si uid null', () {
    test('retourne Map vide sans erreur', () async {
      final container = ProviderContainer(
        overrides: [currentUidProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(historicalStreetsProvider.future);
      expect(result, isEmpty);
    });
  });

  group('aggregationProvider — comportement si uid non-null', () {
    test('traite un stream de sessions correctement', () async {
      const uid = 'user-test-42';
      final controller = StreamController<List<List<String>>>();
      final container = ProviderContainer(
        overrides: [
          currentUidProvider.overrideWith((ref) => uid),
          // Override pour toute combinaison (uid, from) — indépendant du filtre actif
          sessionsStreetIdsStreamProvider.overrideWith(
            (ref, _) => controller.stream,
          ),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(controller.close);

      // Abonner avant d'émettre — évite la perte d'event sur stream single-subscription
      final future = container.read(aggregationProvider.future);
      await Future<void>.delayed(Duration.zero); // laisse le provider s'abonner
      controller.add([
        ['way:10', 'way:20'],
        ['way:20', 'way:30'],
      ]);

      final result = await future;
      expect(result, equals({'way:10', 'way:20', 'way:30'}));
    });
  });
}
