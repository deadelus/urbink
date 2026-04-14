import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/services/transport_mode_detector.dart';

void main() {
  group('TransportModeDetector.classify()', () {
    test('0 m/s → walking', () {
      expect(TransportModeDetector.classify(0.0), TransportMode.walking);
    });

    test('1.5 m/s (~5.4 km/h) → walking', () {
      expect(TransportModeDetector.classify(1.5), TransportMode.walking);
    });

    test('seuil exact 1.944 m/s (7 km/h) → cycling', () {
      expect(
        TransportModeDetector.classify(7.0 / 3.6),
        TransportMode.cycling,
      );
    });

    test('2.5 m/s (~9 km/h) → cycling', () {
      expect(TransportModeDetector.classify(2.5), TransportMode.cycling);
    });

    test('seuil exact 8.333 m/s (30 km/h) → cycling', () {
      expect(
        TransportModeDetector.classify(30.0 / 3.6),
        TransportMode.cycling,
      );
    });

    test('au-dessus de 30 km/h → driving', () {
      expect(
        TransportModeDetector.classify(30.1 / 3.6),
        TransportMode.driving,
      );
    });

    test('10 m/s (36 km/h) → driving', () {
      expect(TransportModeDetector.classify(10.0), TransportMode.driving);
    });
  });

  group('TransportModeDetector.update()', () {
    late TransportModeDetector detector;
    final t0 = DateTime(2026, 4, 14, 10, 0, 0);

    setUp(() => detector = TransportModeDetector());

    test('vitesse invalide (-1.0) → conserve le mode courant (walking par défaut)', () {
      final mode = detector.update(-1.0, t0);
      expect(mode, TransportMode.walking);
    });

    test('vitesse invalide après un mode cycling → conserve cycling', () {
      detector.update(3.0, t0); // cycling
      final mode = detector.update(-1.0, t0.add(const Duration(seconds: 1)));
      expect(mode, TransportMode.cycling);
    });

    test('unique sample walking → walking', () {
      expect(detector.update(1.0, t0), TransportMode.walking);
    });

    test('unique sample cycling', () {
      expect(detector.update(5.0, t0), TransportMode.cycling);
    });

    test('unique sample driving', () {
      expect(detector.update(10.0, t0), TransportMode.driving);
    });

    test('moyenne de la fenêtre — mix walking + driving → cycling si moyenne dans zone vélo', () {
      // 1 m/s + 5 m/s = avg 3 m/s → cycling
      detector.update(1.0, t0);
      final mode = detector.update(5.0, t0.add(const Duration(seconds: 5)));
      expect(mode, TransportMode.cycling);
    });

    test('samples hors fenêtre 30s sont purgés', () {
      // Ajoute un sample driving à t0
      detector.update(10.0, t0);
      // Ajoute un sample walking 31s plus tard → le driving est purgé
      final mode = detector.update(0.5, t0.add(const Duration(seconds: 31)));
      expect(mode, TransportMode.walking);
    });

    test('samples exactement à 30s restent dans la fenêtre', () {
      detector.update(10.0, t0); // driving
      // À exactement 30s : le sample est encore valide (cutoff = t0, non exclu)
      final mode = detector.update(10.0, t0.add(const Duration(seconds: 30)));
      expect(mode, TransportMode.driving);
    });

    test('plusieurs samples dans la fenêtre — moyenne correcte', () {
      // 3 samples walking (1.0 m/s chacun) + 1 driving (10.0 m/s)
      // avg = (1+1+1+10)/4 = 3.25 m/s → cycling
      for (var i = 0; i < 3; i++) {
        detector.update(1.0, t0.add(Duration(seconds: i * 5)));
      }
      final mode = detector.update(10.0, t0.add(const Duration(seconds: 15)));
      expect(mode, TransportMode.cycling);
    });
  });

  group('SessionMetrics.dominantMode via modeTicks', () {
    // Tests déplacés dans session_test.dart — voir T8
  });
}
