import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';
import 'package:urbink/features/map/models/zone_data.dart';
import 'package:urbink/features/map/providers/aggregation_provider.dart';
import 'package:urbink/features/map/providers/zones_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _fakeStreetsMap = {
  'arrond_1': {'way:1', 'way:2', 'way:3'},
  'arrond_2': {'way:4', 'way:5'},
};

final _fakeZones = [
  const ZoneData(
    id: 'arrond_1',
    name: '1er',
    centroid: LatLng(48.86, 2.34),
    polygon: [],
  ),
  const ZoneData(
    id: 'arrond_2',
    name: '2e',
    centroid: LatLng(48.87, 2.35),
    polygon: [],
  ),
];

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  required String? uid,
  Stream<List<List<String>>>? sessionsStream,
}) {
  const from = null; // all-time
  return ProviderContainer(
    overrides: [
      currentUidProvider.overrideWith((ref) => uid),
      arrondissementStreetsProvider.overrideWith(
        (ref) async => _fakeStreetsMap,
      ),
      zonesProviderFamily('arrondissements').overrideWith(
        (ref) async => _fakeZones,
      ),
      if (uid != null)
        sessionsStreetIdsStreamProvider((uid, from)).overrideWith(
          (ref) => sessionsStream ?? const Stream.empty(),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('quartiersProgressionProvider', () {
    test('retourne liste vide si uid null', () async {
      final container = _makeContainer(uid: null);
      addTearDown(container.dispose);

      final value = await container.read(quartiersProgressionProvider.future);
      expect(value, isEmpty);
    });

    test('retourne 0% par quartier si aucune session', () async {
      final controller = StreamController<List<List<String>>>();
      final container =
          _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([]);

      final progressions =
          await container.read(quartiersProgressionProvider.future);

      expect(progressions, hasLength(2));
      expect(progressions.every((q) => q.exploredStreets == 0), isTrue);
      expect(progressions.every((q) => q.completionPercent == 0.0), isTrue);
    });

    test('calcule le % de complétion correctement', () async {
      final controller = StreamController<List<List<String>>>();
      final container =
          _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      // way:1 et way:2 explorés (2/3 du 1er, 0/2 du 2e)
      controller.add([
        ['way:1', 'way:2'],
      ]);

      final progressions =
          await container.read(quartiersProgressionProvider.future);

      final arrond1 = progressions.firstWhere((q) => q.id == 'arrond_1');
      final arrond2 = progressions.firstWhere((q) => q.id == 'arrond_2');

      expect(arrond1.exploredStreets, 2);
      expect(arrond1.totalStreets, 3);
      expect(arrond1.completionPercent, closeTo(66.67, 0.01));

      expect(arrond2.exploredStreets, 0);
      expect(arrond2.completionPercent, 0.0);
    });

    test('trie par % décroissant', () async {
      final controller = StreamController<List<List<String>>>();
      final container =
          _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      // 2/3 arrond_1 (66.7%) vs 2/2 arrond_2 (100%)
      controller.add([
        ['way:1', 'way:2', 'way:4', 'way:5'],
      ]);

      final progressions =
          await container.read(quartiersProgressionProvider.future);

      expect(progressions.first.id, 'arrond_2'); // 100%
      expect(progressions.last.id, 'arrond_1');  // 66.7%
    });

    test('réagit aux nouvelles sessions', () async {
      final controller = StreamController<List<List<String>>>(sync: true);
      final container =
          _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      final emissions = <List<QuartierProgression>>[];
      final sub = container.listen(
        quartiersProgressionProvider,
        (_, next) => next.whenData(emissions.add),
      );
      addTearDown(sub.close);

      controller.add([]);
      await Future<void>.delayed(Duration.zero);
      controller.add([
        ['way:1'],
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(emissions.length, 2);
      final first = emissions[0].firstWhere((q) => q.id == 'arrond_1');
      final second = emissions[1].firstWhere((q) => q.id == 'arrond_1');
      expect(first.exploredStreets, 0);
      expect(second.exploredStreets, 1);
    });

    test('déduplique les streetIds entre sessions', () async {
      final controller = StreamController<List<List<String>>>();
      final container =
          _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([
        ['way:1', 'way:2'],
        ['way:1'], // doublon
      ]);

      final progressions =
          await container.read(quartiersProgressionProvider.future);
      final arrond1 = progressions.firstWhere((q) => q.id == 'arrond_1');
      expect(arrond1.exploredStreets, 2); // pas 3
    });

    test('ignore les streetIds hors arrondissements connus', () async {
      final controller = StreamController<List<List<String>>>();
      final container =
          _makeContainer(uid: 'user1', sessionsStream: controller.stream);
      addTearDown(container.dispose);
      addTearDown(controller.close);

      controller.add([
        ['way:999', 'way:888'], // IDs inconnus
      ]);

      final progressions =
          await container.read(quartiersProgressionProvider.future);
      expect(progressions.every((q) => q.exploredStreets == 0), isTrue);
    });
  });
}
