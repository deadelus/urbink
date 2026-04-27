import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/features/map/providers/monument_proximity_provider.dart';
import 'package:urbink/features/map/providers/monuments_provider.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/services/gps_tracking_service.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

// ---------------------------------------------------------------------------
// Fake GPS service
// ---------------------------------------------------------------------------

class _FakeGpsService extends GpsTrackingService {
  final Stream<Position> _stream;
  _FakeGpsService(this._stream);

  @override
  Stream<Position> positionStream() => _stream;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Position _position(double lat, double lon) => Position(
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

// Tour Eiffel : 48.8584, 2.2945
const _tourEiffel = Monument(
  id: 'tour-eiffel',
  name: 'Tour Eiffel',
  category: 'Palais & Monuments emblématiques',
  categoryIcon: '🗼',
  subtype: '',
  position: LatLng(48.8584, 2.2945),
);

ProviderContainer _makeContainer({
  required SessionState sessionState,
  required Stream<Position> gpsStream,
  required List<Monument> monuments,
}) {
  return ProviderContainer(
    overrides: [
      sessionStateProvider.overrideWith((ref) => sessionState),
      gpsTrackingServiceProvider.overrideWith(
        (ref) => _FakeGpsService(gpsStream),
      ),
      monumentsProvider.overrideWith((ref) async => monuments),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('monumentProximityStreamProvider', () {
    test('n\'émet rien quand session est idle', () async {
      final posStream = Stream.value(_position(48.8584, 2.2945));
      final container = _makeContainer(
        sessionState: SessionState.idle,
        gpsStream: posStream,
        monuments: [_tourEiffel],
      );
      addTearDown(container.dispose);

      container.read(monumentProximityStreamProvider);
      await Future.delayed(Duration.zero);

      expect(
        container.read(monumentProximityStreamProvider).valueOrNull,
        isNull,
      );
    });

    test('n\'émet rien quand aucun monument dans la liste', () async {
      final posStream = Stream.value(_position(48.8584, 2.2945));
      final container = _makeContainer(
        sessionState: SessionState.active,
        gpsStream: posStream,
        monuments: const [],
      );
      addTearDown(container.dispose);

      container.read(monumentProximityStreamProvider);
      await Future.delayed(Duration.zero);

      expect(
        container.read(monumentProximityStreamProvider).valueOrNull,
        isNull,
      );
    });

    test('émet le monument quand position ≤ 100m', () async {
      // Exactement sur le monument → distance = 0 → ≤ 100m
      final posStream = Stream.value(_position(48.8584, 2.2945));
      final container = _makeContainer(
        sessionState: SessionState.active,
        gpsStream: posStream,
        monuments: [_tourEiffel],
      );
      addTearDown(container.dispose);

      // Attend que monumentsProvider soit résolu avant d'écouter le stream
      await container.read(monumentsProvider.future);

      final emitted = <Monument>[];
      container.listen(
        monumentProximityStreamProvider,
        (_, next) {
          final m = next.valueOrNull;
          if (m != null) emitted.add(m);
        },
        fireImmediately: true,
      );
      // Laisse le stream async* s'exécuter
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emitted, isNotEmpty);
      expect(emitted.first.id, 'tour-eiffel');
    });

    test('n\'émet rien quand position > 100m', () async {
      // ~200m au nord de la Tour Eiffel
      final posStream = Stream.value(_position(48.8602, 2.2945));
      final container = _makeContainer(
        sessionState: SessionState.active,
        gpsStream: posStream,
        monuments: [_tourEiffel],
      );
      addTearDown(container.dispose);

      await container.read(monumentsProvider.future);

      final emitted = <Monument>[];
      container.listen(
        monumentProximityStreamProvider,
        (_, next) {
          final m = next.valueOrNull;
          if (m != null) emitted.add(m);
        },
        fireImmediately: true,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emitted, isEmpty);
    });
  });

  group('kMonumentProximityRadiusMeters', () {
    test('rayon défini à 100m', () {
      expect(kMonumentProximityRadiusMeters, 100.0);
    });
  });
}
