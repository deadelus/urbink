import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/profile/providers/sessions_list_provider.dart';
import 'package:urbink/features/profile/providers/week_sessions_provider.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Session _session({
  required String id,
  required DateTime start,
  List<String> streetIds = const [],
}) =>
    Session(
      sessionId: id,
      userId: 'user1',
      sessionStart: start,
      mode: TransportMode.walking,
      streetIds: streetIds,
      distanceMeters: 500,
    );

ProviderContainer _makeContainer({
  required String? uid,
  SessionsPageFetcher? fetcher,
  DateTime? selectedDay,
}) {
  return ProviderContainer(
    overrides: [
      currentUidProvider.overrideWith((ref) => uid),
      if (fetcher != null) sessionsPageFetcherProvider.overrideWith((ref) => fetcher),
      if (selectedDay != null)
        selectedHistogramDayProvider.overrideWith((ref) => selectedDay),
    ],
  );
}

SessionsPageFetcher _staticFetcher(List<Session> sessions) =>
    (uid, {required selectedDay, required cursor}) async =>
        (sessions: sessions, nextCursor: null);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('sessionsByDayProvider', () {
    test('retourne vide quand uid est null', () async {
      final container = _makeContainer(uid: null);
      addTearDown(container.dispose);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.sessions, isEmpty);
      expect(value.hasMore, false);
    });

    test('retourne la première page quand selectedDay est null', () async {
      final sessions = [
        _session(id: 's1', start: DateTime(2026, 4, 20, 8)),
        _session(id: 's2', start: DateTime(2026, 4, 21, 9)),
        _session(id: 's3', start: DateTime(2026, 4, 22, 10)),
      ];
      final container = _makeContainer(
        uid: 'user1',
        fetcher: _staticFetcher(sessions),
      );
      addTearDown(container.dispose);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.sessions.length, 3);
      expect(value.hasMore, false); // 3 < kSessionsPageSize
    });

    test('hasMore est true quand la page est pleine (kSessionsPageSize)', () async {
      final sessions = List.generate(
        kSessionsPageSize,
        (i) => _session(id: 's$i', start: DateTime(2026, 4, 20)),
      );
      final container = _makeContainer(
        uid: 'user1',
        fetcher: (uid, {required selectedDay, required cursor}) async =>
            (sessions: sessions, nextCursor: 'cursor_token'),
      );
      addTearDown(container.dispose);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.sessions.length, kSessionsPageSize);
      expect(value.hasMore, true);
    });

    test('filtre par jour sélectionné — le fetcher reçoit selectedDay', () async {
      final tuesday = DateTime(2026, 4, 21);
      final filtered = [
        _session(id: 's2', start: DateTime(2026, 4, 21, 9)),
        _session(id: 's3', start: DateTime(2026, 4, 21, 15)),
      ];
      DateTime? capturedDay;
      final container = _makeContainer(
        uid: 'user1',
        fetcher: (uid, {required selectedDay, required cursor}) async {
          capturedDay = selectedDay;
          return (sessions: filtered, nextCursor: null);
        },
        selectedDay: tuesday,
      );
      addTearDown(container.dispose);

      final value = await container.read(sessionsByDayProvider.future);
      expect(capturedDay, tuesday);
      expect(value.sessions.length, 2);
      expect(value.hasMore, false);
    });

    test('retourne liste vide si aucune session ce jour', () async {
      final container = _makeContainer(
        uid: 'user1',
        fetcher: _staticFetcher([]),
        selectedDay: DateTime(2026, 4, 25),
      );
      addTearDown(container.dispose);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.sessions, isEmpty);
    });

    test('loadMore appende les sessions de la page suivante', () async {
      final page1 = List.generate(
        kSessionsPageSize,
        (i) => _session(id: 'p1_s$i', start: DateTime(2026, 4, 20)),
      );
      final page2 = [
        _session(id: 'p2_s0', start: DateTime(2026, 4, 19)),
      ];
      int callCount = 0;
      final container = _makeContainer(
        uid: 'user1',
        fetcher: (uid, {required selectedDay, required cursor}) async {
          callCount++;
          return callCount == 1
              ? (sessions: page1, nextCursor: 'cursor_1')
              : (sessions: page2, nextCursor: null);
        },
      );
      addTearDown(container.dispose);

      await container.read(sessionsByDayProvider.future);
      await container.read(sessionsByDayProvider.notifier).loadMore();

      final value = container.read(sessionsByDayProvider).requireValue;
      expect(value.sessions.length, kSessionsPageSize + 1);
      expect(value.sessions.last.sessionId, 'p2_s0');
      expect(value.hasMore, false);
      expect(value.isLoadingMore, false);
    });

    test('loadMore est no-op si hasMore est false', () async {
      int callCount = 0;
      final container = _makeContainer(
        uid: 'user1',
        fetcher: (uid, {required selectedDay, required cursor}) async {
          callCount++;
          return (
            sessions: [_session(id: 's1', start: DateTime(2026, 4, 20))],
            nextCursor: null,
          );
        },
      );
      addTearDown(container.dispose);

      await container.read(sessionsByDayProvider.future);
      await container.read(sessionsByDayProvider.notifier).loadMore();

      expect(callCount, 1); // loadMore ignoré car hasMore == false
    });
  });
}
