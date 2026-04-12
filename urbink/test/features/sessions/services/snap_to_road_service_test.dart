import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/sessions/services/snap_to_road_service.dart';
import 'package:urbink/shared/utils/nominatim_client.dart';

class _FakeNominatimClient extends NominatimClient {
  final NominatimResult? result;

  _FakeNominatimClient(this.result);

  @override
  Future<NominatimResult?> reverseGeocode({
    required double lat,
    required double lon,
  }) async =>
      result;
}

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

void main() {
  group('SnapToRoadService.snapToRoad', () {
    test('retourne le streetId quand Nominatim répond', () async {
      final service = SnapToRoadService(
        nominatimClient: _FakeNominatimClient(
          const NominatimResult(
            streetId: 'way:987654321',
            displayName: 'Rue de Rivoli',
          ),
        ),
      );

      final streetId = await service.snapToRoad(_position(48.8566, 2.3522));

      expect(streetId, 'way:987654321');
    });

    test('retourne null quand Nominatim échoue (fallback silencieux)', () async {
      final service = SnapToRoadService(
        nominatimClient: _FakeNominatimClient(null),
      );

      final streetId = await service.snapToRoad(_position(48.8566, 2.3522));

      expect(streetId, isNull);
    });
  });
}
