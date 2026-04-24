import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
      distanceMeters: 0,
    );

ProviderContainer _makeContainer({
  required String? uid,
  required DateTime weekStartDate,
  Stream<List<Session>>? stream,
}) {
  return ProviderContainer(
    overrides: [
      currentUidProvider.overrideWith((ref) => uid),
      if (uid != null)
        weekSessionsRawStreamProvider((uid, weekStartDate)).overrideWith(
          (ref) => stream ?? const Stream.empty(),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// weekStart helper
// ---------------------------------------------------------------------------

void main() {
  group('weekStart', () {
    test('retourne le lundi de la semaine à minuit', () {
      // 2026-04-24 est un vendredi (weekday=5)
      final friday = DateTime(2026, 4, 24, 15, 30);
      final result = weekStart(friday);
      expect(result, DateTime(2026, 4, 20)); // lundi précédent
    });

    test('retourne le lundi lui-même si on est lundi', () {
      final monday = DateTime(2026, 4, 20, 9, 0);
      expect(weekStart(monday), DateTime(2026, 4, 20));
    });

    test('retourne le lundi correct pour un dimanche', () {
      final sunday = DateTime(2026, 4, 26, 23, 59);
      expect(weekStart(sunday), DateTime(2026, 4, 20));
    });
  });

  // ---------------------------------------------------------------------------
  // weekSessionsProvider
  // ---------------------------------------------------------------------------

  group('weekSessionsProvider', () {
    late DateTime monday;

    setUp(() => monday = DateTime(2026, 4, 20));

    test('retourne une Map vide quand uid est null', () async {
      final container = _makeContainer(
        uid: null,
        weekStartDate: monday,
      );
      addTearDown(container.dispose);

      final value = await container.read(weekSessionsProvider.future);
      expect(value, isEmpty);
    });

    test('retourne une Map vide quand aucune session cette semaine', () async {
      final ctrl = StreamController<List<Session>>();
      final container = _makeContainer(
        uid: 'user1',
        weekStartDate: monday,
        stream: ctrl.stream,
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      ctrl.add([]);

      final value = await container.read(weekSessionsProvider.future);
      expect(value, isEmpty);
    });

    test('agrège les streetIds uniques par jour', () async {
      final ctrl = StreamController<List<Session>>();
      final container = _makeContainer(
        uid: 'user1',
        weekStartDate: monday,
        stream: ctrl.stream,
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      final tuesday = DateTime(2026, 4, 21, 10, 0);
      ctrl.add([
        _session(
          id: 's1',
          start: tuesday,
          streetIds: ['way:1', 'way:2'],
        ),
        _session(
          id: 's2',
          start: tuesday.add(const Duration(hours: 2)),
          streetIds: ['way:2', 'way:3'],
        ),
      ]);

      final value = await container.read(weekSessionsProvider.future);
      final dayKey = DateTime(2026, 4, 21);
      expect(value[dayKey], 3); // way:1, way:2, way:3 (dédupliqué)
    });

    test('groupe correctement sur plusieurs jours différents', () async {
      final ctrl = StreamController<List<Session>>();
      final container = _makeContainer(
        uid: 'user1',
        weekStartDate: monday,
        stream: ctrl.stream,
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      ctrl.add([
        _session(
          id: 's1',
          start: DateTime(2026, 4, 20, 8, 0), // lundi
          streetIds: ['way:A'],
        ),
        _session(
          id: 's2',
          start: DateTime(2026, 4, 22, 9, 0), // mercredi
          streetIds: ['way:B', 'way:C'],
        ),
      ]);

      final value = await container.read(weekSessionsProvider.future);
      expect(value[DateTime(2026, 4, 20)], 1);
      expect(value[DateTime(2026, 4, 22)], 2);
      expect(value.length, 2);
    });

    test('session sans streetIds ne crée pas de clé dans la Map', () async {
      final ctrl = StreamController<List<Session>>();
      final container = _makeContainer(
        uid: 'user1',
        weekStartDate: monday,
        stream: ctrl.stream,
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      ctrl.add([
        _session(id: 's1', start: DateTime(2026, 4, 21), streetIds: []),
      ]);

      final value = await container.read(weekSessionsProvider.future);
      expect(value[DateTime(2026, 4, 21)], isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // selectedHistogramDayProvider
  // ---------------------------------------------------------------------------

  group('selectedHistogramDayProvider', () {
    test('vaut null par défaut', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(selectedHistogramDayProvider), isNull);
    });

    test('peut être mis à jour', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final day = DateTime(2026, 4, 21);
      container.read(selectedHistogramDayProvider.notifier).state = day;
      expect(container.read(selectedHistogramDayProvider), day);
    });

    test('peut être réinitialisé à null (toggle)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final day = DateTime(2026, 4, 21);
      container.read(selectedHistogramDayProvider.notifier).state = day;
      container.read(selectedHistogramDayProvider.notifier).state = null;
      expect(container.read(selectedHistogramDayProvider), isNull);
    });
  });
}
