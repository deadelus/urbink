import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/sessions/services/gps_tracking_service.dart';

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
  group('GpsTrackingService.hasMovedEnoughBetween', () {
    test('retourne true si distance >= 10m', () {
      // ~11m vers le nord depuis (48.8566, 2.3522)
      final last = _position(48.8566, 2.3522);
      final current = _position(48.8567, 2.3522);

      expect(
        GpsTrackingService.hasMovedEnoughBetween(last, current),
        isTrue,
      );
    });

    test('retourne false si distance < 10m', () {
      // ~1m vers le nord
      final last = _position(48.85660, 2.35220);
      final current = _position(48.85661, 2.35220);

      expect(
        GpsTrackingService.hasMovedEnoughBetween(last, current),
        isFalse,
      );
    });

    test('retourne true si distance exactement = 10m', () {
      // ~10m vers le nord depuis (48.8566, 2.3522)
      final last = _position(48.85660, 2.35220);
      final current = _position(48.85669, 2.35220);

      expect(
        GpsTrackingService.hasMovedEnoughBetween(last, current),
        isTrue,
      );
    });

    test('retourne true pour des positions très éloignées', () {
      final paris = _position(48.8566, 2.3522);
      final lyon = _position(45.7640, 4.8357);

      expect(
        GpsTrackingService.hasMovedEnoughBetween(paris, lyon),
        isTrue,
      );
    });
  });
}
