import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/services/session_local_cache.dart';

void main() {
  late SessionLocalCache cache;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    cache = SessionLocalCache(dbPath: inMemoryDatabasePath);
  });

  tearDown(() async {
    await cache.close();
  });

  Session makeSession({
    String id = 'sess-1',
    DateTime? end,
    bool withStreets = true,
  }) {
    return Session(
      sessionId: id,
      userId: 'user-abc',
      sessionStart: DateTime(2026, 4, 14, 10, 0, 0),
      sessionEnd: end,
      mode: TransportMode.walking,
      streetIds: withStreets ? ['way/1', 'way/2'] : [],
      distanceMeters: 500.0,
    );
  }

  group('insertSession / getInterruptedSession', () {
    test('session active retournée par getInterruptedSession', () async {
      final active = makeSession();
      await cache.insertSession(active);

      final interrupted = await cache.getInterruptedSession();
      expect(interrupted, isNotNull);
      expect(interrupted!.sessionId, 'sess-1');
      expect(interrupted.sessionEnd, isNull);
    });

    test('session terminée non retournée', () async {
      final done = makeSession(end: DateTime(2026, 4, 14, 10, 30));
      await cache.insertSession(done);

      final interrupted = await cache.getInterruptedSession();
      expect(interrupted, isNull);
    });

    test('plusieurs sessions — retourne la plus récente interrompue', () async {
      final old = makeSession(id: 'sess-old').copyWith(
        sessionStart: DateTime(2026, 4, 14, 9, 0),
      );
      final recent = makeSession(id: 'sess-recent').copyWith(
        sessionStart: DateTime(2026, 4, 14, 10, 0),
      );
      await cache.insertSession(old);
      await cache.insertSession(recent);

      final interrupted = await cache.getInterruptedSession();
      expect(interrupted!.sessionId, 'sess-recent');
    });
  });

  group('updateSession', () {
    test('met à jour session_end et métriques', () async {
      final active = makeSession();
      await cache.insertSession(active);

      final end = DateTime(2026, 4, 14, 10, 30);
      final updated = active.copyWith(
        sessionEnd: end,
        distanceMeters: 1200.0,
        streetIds: ['way/1', 'way/2', 'way/3'],
      );
      await cache.updateSession(updated);

      // Après update, session_end != null → plus retournée par getInterruptedSession
      final interrupted = await cache.getInterruptedSession();
      expect(interrupted, isNull);
    });
  });

  group('markSynced', () {
    test('session marquée synced non retournée par getUnsyncedSessions', () async {
      final end = DateTime(2026, 4, 14, 10, 30);
      final done = makeSession(end: end);
      await cache.insertSession(done);

      final beforeSync = await cache.getUnsyncedSessions();
      expect(beforeSync.length, 1);

      await cache.markSynced('sess-1');

      final afterSync = await cache.getUnsyncedSessions();
      expect(afterSync, isEmpty);
    });
  });

  group('markCancelled', () {
    test('session interrompue abandonnée disparaît du crash recovery', () async {
      final active = makeSession();
      await cache.insertSession(active);

      await cache.markCancelled('sess-1');

      final interrupted = await cache.getInterruptedSession();
      expect(interrupted, isNull);
    });
  });

  group('getUnsyncedSessions', () {
    test('retourne uniquement sessions terminées non-syncées', () async {
      final active = makeSession(id: 'active');
      final done = makeSession(
        id: 'done',
        end: DateTime(2026, 4, 14, 10, 30),
      );
      await cache.insertSession(active);
      await cache.insertSession(done);

      final unsynced = await cache.getUnsyncedSessions();
      expect(unsynced.length, 1);
      expect(unsynced.first.sessionId, 'done');
    });
  });
}
