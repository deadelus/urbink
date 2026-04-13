import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

void main() {
  final start = DateTime(2026, 4, 14, 10, 0, 0);
  final end = DateTime(2026, 4, 14, 10, 30, 0);

  final session = Session(
    sessionId: 'test-id-123',
    userId: 'user-abc',
    sessionStart: start,
    sessionEnd: end,
    mode: TransportMode.walking,
    streetIds: ['way/111', 'way/222'],
    distanceMeters: 1500.0,
  );

  group('Session.toSqflite / fromSqflite', () {
    test('round-trip complet', () {
      final row = session.toSqflite();
      final restored = Session.fromSqflite(row);

      expect(restored.sessionId, session.sessionId);
      expect(restored.userId, session.userId);
      expect(restored.sessionStart, session.sessionStart);
      expect(restored.sessionEnd, session.sessionEnd);
      expect(restored.mode, session.mode);
      expect(restored.streetIds, session.streetIds);
      expect(restored.distanceMeters, session.distanceMeters);
    });

    test('session_end null si session active', () {
      final active = session.copyWith(clearSessionEnd: true);
      final row = active.toSqflite();
      expect(row['session_end'], isNull);
      final restored = Session.fromSqflite(row);
      expect(restored.sessionEnd, isNull);
    });

    test('streetIds vide', () {
      final empty = session.copyWith(streetIds: []);
      final row = empty.toSqflite();
      final restored = Session.fromSqflite(row);
      expect(restored.streetIds, isEmpty);
    });
  });

  group('Session.toFirestore / fromFirestore', () {
    test('round-trip complet', () {
      final map = session.toFirestore();

      expect(map['mode'], 'walk');
      expect(map['streetIds'], ['way/111', 'way/222']);
      expect(map['distanceMeters'], 1500.0);
      expect(map['sessionStart'], isA<Timestamp>());
      expect(map['sessionEnd'], isA<Timestamp>());
    });

    test('fromFirestore reconstruit correctement', () {
      final map = {
        'sessionStart': Timestamp.fromDate(start),
        'sessionEnd': Timestamp.fromDate(end),
        'mode': 'walk',
        'streetIds': ['way/111', 'way/222'],
        'distanceMeters': 1500.0,
      };
      final restored = Session.fromFirestore('test-id-123', 'user-abc', map);

      expect(restored.sessionId, 'test-id-123');
      expect(restored.mode, TransportMode.walking);
      expect(restored.streetCount, 2);
      expect(restored.distanceKm, 1.5);
    });

    test('mode bike/car round-trip', () {
      final bike = session.copyWith(mode: TransportMode.cycling);
      expect(bike.toFirestore()['mode'], 'bike');
      expect(
        Session.fromFirestore('x', 'y', bike.toFirestore()..remove('createdAt')).mode,
        TransportMode.cycling,
      );

      final car = session.copyWith(mode: TransportMode.driving);
      expect(car.toFirestore()['mode'], 'car');
    });
  });

  group('Session computed properties', () {
    test('streetCount', () => expect(session.streetCount, 2));
    test('distanceKm', () => expect(session.distanceKm, 1.5));
    test('duration', () => expect(session.duration, const Duration(minutes: 30)));
  });

  group('Session.copyWith', () {
    test('modifie uniquement les champs spécifiés', () {
      final updated = session.copyWith(distanceMeters: 2000.0);
      expect(updated.distanceMeters, 2000.0);
      expect(updated.sessionId, session.sessionId);
      expect(updated.streetIds, session.streetIds);
    });
  });
}
