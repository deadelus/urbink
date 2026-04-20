import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/providers/aggregation_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  required String? uid,
  Stream<List<List<String>>>? sessionsStream,
}) {
  return ProviderContainer(
    overrides: [
      currentUidProvider.overrideWith((ref) => uid),
      if (uid != null)
        sessionsStreetIdsStreamProvider(uid).overrideWith(
          (ref) => sessionsStream ?? const Stream.empty(),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('aggregationProvider', () {
    test('retourne un Set vide quand uid est null', () async {
      final container = _makeContainer(uid: null);
      addTearDown(container.dispose);

      final value = await container.read(aggregationProvider.future);
      expect(value, isEmpty);
    });

    test('retourne un Set vide quand aucune session', () async {
      final controller = StreamController<List<List<String>>>();
      final container = _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([]);

      final value = await container.read(aggregationProvider.future);
      expect(value, isEmpty);
    });

    test('union de streetIds depuis plusieurs sessions', () async {
      final controller = StreamController<List<List<String>>>();
      final container = _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([
        ['way:1', 'way:2'],
        ['way:2', 'way:3'],
      ]);

      final value = await container.read(aggregationProvider.future);
      expect(value, {'way:1', 'way:2', 'way:3'});
    });

    test('déduplique les streetIds partagés entre sessions', () async {
      final controller = StreamController<List<List<String>>>();
      final container = _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([
        ['way:42', 'way:42'],
        ['way:42'],
      ]);

      final value = await container.read(aggregationProvider.future);
      expect(value, {'way:42'});
    });

    test('se met à jour automatiquement quand une nouvelle session arrive', () async {
      final controller = StreamController<List<List<String>>>(sync: true);
      final container = _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      final emissions = <Set<String>>[];
      final sub = container.listen(
        aggregationProvider,
        (_, next) => next.whenData(emissions.add),
      );
      addTearDown(sub.close);

      controller.add([
        ['way:1'],
      ]);
      await Future<void>.delayed(Duration.zero);

      controller.add([
        ['way:1'],
        ['way:2'],
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(emissions.length, 2);
      expect(emissions[0], {'way:1'});
      expect(emissions[1], {'way:1', 'way:2'});
    });

    test('tolère une session avec une liste vide de streetIds', () async {
      final controller = StreamController<List<List<String>>>();
      final container = _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([
        [],
        ['way:5'],
      ]);

      final value = await container.read(aggregationProvider.future);
      expect(value, {'way:5'});
    });
  });
}
