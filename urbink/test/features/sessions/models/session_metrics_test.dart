import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/sessions/models/session_metrics.dart';

void main() {
  group('SessionMetrics', () {
    test('valeurs par défaut', () {
      const m = SessionMetrics();
      expect(m.streetCount, 0);
      expect(m.distanceKm, 0.0);
      expect(m.elapsed, Duration.zero);
      expect(m.sessionStartTime, isNull);
    });

    test('streetCount = nombre d\'IDs uniques', () {
      const m = SessionMetrics(
        exploredStreetIds: {'way:1', 'way:2', 'way:3'},
      );
      expect(m.streetCount, 3);
    });

    test('distanceKm = distanceMeters / 1000', () {
      const m = SessionMetrics(distanceMeters: 2500);
      expect(m.distanceKm, closeTo(2.5, 0.001));
    });

    test('elapsed > zero quand sessionStartTime est défini', () {
      final start = DateTime.now().subtract(const Duration(minutes: 5));
      final m = SessionMetrics(sessionStartTime: start);
      expect(m.elapsed.inSeconds, greaterThan(0));
    });

    test('copyWith met à jour les champs sélectionnés', () {
      const m = SessionMetrics(distanceMeters: 100);
      final updated = m.copyWith(distanceMeters: 500);
      expect(updated.distanceMeters, 500);
      expect(updated.sessionStartTime, isNull);
    });

    test('copyWith préserve les champs non modifiés', () {
      final start = DateTime(2026, 4, 13);
      final m = SessionMetrics(
        sessionStartTime: start,
        distanceMeters: 200,
        exploredStreetIds: const {'way:42'},
      );
      final updated = m.copyWith(distanceMeters: 300);
      expect(updated.sessionStartTime, start);
      expect(updated.exploredStreetIds, contains('way:42'));
    });
  });

  group('TransportMode', () {
    // Tests dans transport_mode_test.dart
  });
}
