import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/session_metrics.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_db_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';
import 'package:urbink/features/sessions/providers/transport_mode_provider.dart';
import 'package:urbink/features/sessions/services/session_local_cache.dart';
import 'package:urbink/features/sessions/services/session_repository.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

// ---------------------------------------------------------------------------
// Fausse implémentation du TransportModeNotifier — sans SharedPreferences
// ---------------------------------------------------------------------------

class _FakeTransportModeNotifier extends TransportModeNotifier {
  @override
  TransportMode build() => TransportMode.walking; // pas de SharedPreferences
}

// ---------------------------------------------------------------------------
// Fausse implémentation du repository — pas de dépendance Firestore en test
// ---------------------------------------------------------------------------

class FakeSessionRepository implements SessionRepository {
  final List<Session> saved = [];
  bool throwOnSave = false;

  @override
  Future<void> saveSession(Session session) async {
    if (throwOnSave) throw Exception('network error');
    saved.add(session);
  }

  @override
  Future<void> syncSessions(List<Session> sessions) async {
    if (throwOnSave) throw Exception('network error');
    saved.addAll(sessions);
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  ProviderContainer makeContainer({
    FakeSessionRepository? repo,
    SessionLocalCache? cache,
  }) {
    return ProviderContainer(
      overrides: [
        sessionLocalCacheProvider.overrideWithValue(cache ?? SessionLocalCache(dbPath: inMemoryDatabasePath)),
        sessionRepositoryProvider.overrideWithValue(repo ?? FakeSessionRepository()),
        // Pas de SharedPreferences en test — mode fixe walking
        transportModeProvider.overrideWith(() => _FakeTransportModeNotifier()),
        // Stream vide — pas de connectivité native en test
        connectivityChangesProvider.overrideWith(
          (ref) => const Stream<List<ConnectivityResult>>.empty(),
        ),
      ],
    );
  }

  group('état initial', () {
    test('state est null au démarrage', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(sessionLifecycleProvider), isNull);
    });
  });

  group('stopAndSave', () {
    test('retourne null si aucune session active', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container
          .read(sessionLifecycleProvider.notifier)
          .stopAndSave(const SessionMetrics());

      expect(result, isNull);
    });

    test('sauvegarde métriques et appelle Firestore', () async {
      final cache = SessionLocalCache(dbPath: inMemoryDatabasePath);
      final repo = FakeSessionRepository();
      final container = makeContainer(repo: repo, cache: cache);
      addTearDown(() async {
        container.dispose();
        await cache.close();
      });

      // Injecter une session active
      final fakeSession = Session(
        sessionId: 'fake-id',
        userId: 'user-test',
        sessionStart: DateTime(2026, 4, 14, 10, 0),
        mode: TransportMode.walking,
        streetIds: const [],
        distanceMeters: 0,
      );
      await cache.insertSession(fakeSession);
      // ignore: invalid_use_of_protected_member
      container.read(sessionLifecycleProvider.notifier).state = fakeSession;

      final metrics = SessionMetrics(
        sessionStartTime: DateTime(2026, 4, 14, 10, 0),
        distanceMeters: 800.0,
        exploredStreetIds: const {'way/1', 'way/2'},
      );

      final result = await container
          .read(sessionLifecycleProvider.notifier)
          .stopAndSave(metrics);

      expect(result, isNotNull);
      expect(result!.distanceMeters, 800.0);
      expect(result.streetIds, containsAll(['way/1', 'way/2']));
      expect(result.sessionEnd, isNotNull);
      expect(repo.saved, hasLength(1));
    });

    test('session reste dans sqflite si Firestore échoue (offline)', () async {
      final cache = SessionLocalCache(dbPath: inMemoryDatabasePath);
      final repo = FakeSessionRepository()..throwOnSave = true;
      final container = makeContainer(repo: repo, cache: cache);
      addTearDown(() async {
        container.dispose();
        await cache.close();
      });

      final fakeSession = Session(
        sessionId: 'offline-id',
        userId: 'user-test',
        sessionStart: DateTime(2026, 4, 14, 10, 0),
        mode: TransportMode.walking,
        streetIds: const [],
        distanceMeters: 0,
      );
      await cache.insertSession(fakeSession);
      // ignore: invalid_use_of_protected_member
      container.read(sessionLifecycleProvider.notifier).state = fakeSession;

      final result = await container
          .read(sessionLifecycleProvider.notifier)
          .stopAndSave(const SessionMetrics(distanceMeters: 300.0));

      // Session retournée malgré l'échec Firestore
      expect(result, isNotNull);
      // Elle est dans sqflite (non-syncée)
      final unsynced = await cache.getUnsyncedSessions();
      expect(unsynced, hasLength(1));
      expect(unsynced.first.sessionId, 'offline-id');
    });
  });

  group('cancelInterrupted', () {
    test('session interrompue disparaît du crash recovery', () async {
      final cache = SessionLocalCache(dbPath: inMemoryDatabasePath);
      final container = makeContainer(cache: cache);
      addTearDown(() async {
        container.dispose();
        await cache.close();
      });

      final session = Session(
        sessionId: 'crash-id',
        userId: 'user-test',
        sessionStart: DateTime(2026, 4, 14, 9, 0),
        mode: TransportMode.walking,
        streetIds: const [],
        distanceMeters: 0,
      );
      await cache.insertSession(session);

      await container
          .read(sessionLifecycleProvider.notifier)
          .cancelInterrupted('crash-id');

      expect(await cache.getInterruptedSession(), isNull);
    });
  });

  group('resumeFromCrash', () {
    test('restaure state et passe sessionStateProvider à active', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final session = Session(
        sessionId: 'crash-id',
        userId: 'user-test',
        sessionStart: DateTime(2026, 4, 14, 9, 0),
        mode: TransportMode.cycling,
        streetIds: const [],
        distanceMeters: 0,
      );

      await container
          .read(sessionLifecycleProvider.notifier)
          .resumeFromCrash(session);

      expect(container.read(sessionLifecycleProvider)?.sessionId, 'crash-id');
      expect(container.read(sessionStateProvider), SessionState.active);
    });
  });
}
