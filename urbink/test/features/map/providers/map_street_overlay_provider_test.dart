import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/map/providers/map_street_overlay_provider.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/services/snap_to_road_service.dart';

class _FakeSnapToRoadService extends SnapToRoadService {
  final String? streetId;
  _FakeSnapToRoadService(this.streetId);

  @override
  Future<String?> snapToRoad(Position position) async => streetId;
}

Position _pos(double lat, double lon) => Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

ProviderContainer _makeContainer({
  String? snapResult,
  Stream<Position>? positionStream,
}) {
  return ProviderContainer(
    overrides: [
      snapToRoadServiceProvider.overrideWith(
        (ref) => _FakeSnapToRoadService(snapResult),
      ),
      // L'overlay écoute passiveGpsStreamProvider (pas gpsPositionStreamProvider)
      // depuis Story 2.8 — le tracking passif est indépendant de l'état session.
      passiveGpsStreamProvider.overrideWith(
        (ref) => positionStream ?? const Stream.empty(),
      ),
      // Firebase non initialisé en test — UID null = pas d'appel Firestore
      currentUidProvider.overrideWith((ref) => null),
    ],
  );
}

void main() {
  group('MapStreetOverlayNotifier', () {
    test('état initial est vide', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final state = container.read(mapStreetOverlayProvider);
      expect(state.isEmpty, isTrue);
      expect(state.currentStreetId, isNull);
    });

    test('une position GPS ajoute un point à la rue identifiée', () async {
      final position = _pos(48.8566, 2.3522);
      final container = _makeContainer(
        snapResult: 'way:123456',
        positionStream: Stream.value(position),
      );
      addTearDown(container.dispose);

      // Lire le provider pour l'initialiser
      container.read(mapStreetOverlayProvider);

      // Laisser l'async snap to road s'exécuter
      await Future.delayed(Duration.zero);

      final state = container.read(mapStreetOverlayProvider);
      expect(state.exploredStreets['way:123456'], isNotNull);
      expect(state.exploredStreets['way:123456']!.length, 1);
      expect(state.currentStreetId, 'way:123456');
    });

    test('snap to road null ne crash pas et laisse l\'état inchangé', () async {
      final container = _makeContainer(
        snapResult: null,
        positionStream: Stream.value(_pos(48.8566, 2.3522)),
      );
      addTearDown(container.dispose);

      container.read(mapStreetOverlayProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(mapStreetOverlayProvider);
      expect(state.isEmpty, isTrue);
      expect(state.currentStreetId, isNull);
    });

    test('clear() réinitialise l\'état', () async {
      final container = _makeContainer(
        snapResult: 'way:999',
        positionStream: Stream.value(_pos(48.8566, 2.3522)),
      );
      addTearDown(container.dispose);

      container.read(mapStreetOverlayProvider);
      await Future.delayed(Duration.zero);

      container.read(mapStreetOverlayProvider.notifier).clear();

      final state = container.read(mapStreetOverlayProvider);
      expect(state.isEmpty, isTrue);
    });
  });
}
