import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/profile/models/day_stats.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

void main() {
  final now = DateTime(2026, 4, 21); // lundi

  Session makeSession({required int streetCount}) => Session(
        sessionId: 'id',
        userId: 'uid',
        sessionStart: now,
        sessionEnd: now.add(const Duration(minutes: 30)),
        mode: TransportMode.walking,
        streetIds: List.generate(streetCount, (i) => 'street_$i'),
        distanceMeters: streetCount * 100.0,
      );

  group('DayStats.empty', () {
    test('isEmpty est true', () {
      final d = DayStats.empty(now);
      expect(d.isEmpty, isTrue);
      expect(d.streetCount, 0);
      expect(d.distanceKm, 0.0);
      expect(d.totalDuration, Duration.zero);
      expect(d.sessions, isEmpty);
    });
  });

  group('DayStats', () {
    test('isEmpty est false quand sessions non vides', () {
      final s = makeSession(streetCount: 5);
      final d = DayStats(
        date: now,
        streetCount: 5,
        distanceKm: 0.5,
        totalDuration: const Duration(minutes: 30),
        sessions: [s],
      );
      expect(d.isEmpty, isFalse);
      expect(d.streetCount, 5);
    });
  });
}
