import 'dart:async';

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
  Stream<List<Session>>? stream,
  DateTime? selectedDay,
}) {
  return ProviderContainer(
    overrides: [
      currentUidProvider.overrideWith((ref) => uid),
      if (uid != null)
        allSessionsRawStreamProvider(uid).overrideWith(
          (ref) => stream ?? const Stream.empty(),
        ),
      if (selectedDay != null)
        selectedHistogramDayProvider.overrideWith((ref) => selectedDay),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('sessionsByDayProvider', () {
    test('retourne une liste vide quand uid est null', () async {
      final container = _makeContainer(uid: null);
      addTearDown(container.dispose);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value, isEmpty);
    });

    test('retourne toutes les sessions quand selectedDay est null', () async {
      final ctrl = StreamController<List<Session>>();
      final container = _makeContainer(uid: 'user1', stream: ctrl.stream);
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      final sessions = [
        _session(id: 's1', start: DateTime(2026, 4, 20, 8, 0)),
        _session(id: 's2', start: DateTime(2026, 4, 21, 9, 0)),
        _session(id: 's3', start: DateTime(2026, 4, 22, 10, 0)),
      ];
      ctrl.add(sessions);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.length, 3);
    });

    test('filtre par jour sélectionné — retourne uniquement les sessions du jour', () async {
      final ctrl = StreamController<List<Session>>();
      final tuesday = DateTime(2026, 4, 21);
      final container = _makeContainer(
        uid: 'user1',
        stream: ctrl.stream,
        selectedDay: tuesday,
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      ctrl.add([
        _session(id: 's1', start: DateTime(2026, 4, 20, 8, 0)),  // lundi
        _session(id: 's2', start: DateTime(2026, 4, 21, 9, 0)),  // mardi
        _session(id: 's3', start: DateTime(2026, 4, 21, 15, 0)), // mardi aussi
        _session(id: 's4', start: DateTime(2026, 4, 22, 10, 0)), // mercredi
      ]);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.length, 2);
      expect(value.map((s) => s.sessionId), containsAll(['s2', 's3']));
    });

    test('retourne liste vide si aucune session ce jour', () async {
      final ctrl = StreamController<List<Session>>();
      final container = _makeContainer(
        uid: 'user1',
        stream: ctrl.stream,
        selectedDay: DateTime(2026, 4, 25),
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      ctrl.add([
        _session(id: 's1', start: DateTime(2026, 4, 20, 8, 0)),
      ]);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value, isEmpty);
    });

    test('filtre correctement les sessions à minuit et en fin de journée', () async {
      final ctrl = StreamController<List<Session>>();
      final wednesday = DateTime(2026, 4, 22);
      final container = _makeContainer(
        uid: 'user1',
        stream: ctrl.stream,
        selectedDay: wednesday,
      );
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      ctrl.add([
        _session(id: 's1', start: DateTime(2026, 4, 22, 0, 0, 0)),   // minuit
        _session(id: 's2', start: DateTime(2026, 4, 22, 23, 59, 59)), // fin de journée
        _session(id: 's3', start: DateTime(2026, 4, 23, 0, 0, 0)),   // lendemain
      ]);

      final value = await container.read(sessionsByDayProvider.future);
      expect(value.length, 2);
      expect(value.map((s) => s.sessionId), containsAll(['s1', 's2']));
    });

    test('se met à jour réactivement quand le stream émet de nouvelles sessions', () async {
      final ctrl = StreamController<List<Session>>(sync: true);
      final container = _makeContainer(uid: 'user1', stream: ctrl.stream);
      addTearDown(container.dispose);
      addTearDown(ctrl.close);

      final emissions = <List<Session>>[];
      final sub = container.listen(
        sessionsByDayProvider,
        (_, next) => next.whenData(emissions.add),
      );
      addTearDown(sub.close);

      ctrl.add([_session(id: 's1', start: DateTime(2026, 4, 20))]);
      await Future<void>.delayed(Duration.zero);

      ctrl.add([
        _session(id: 's1', start: DateTime(2026, 4, 20)),
        _session(id: 's2', start: DateTime(2026, 4, 21)),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(emissions.length, 2);
      expect(emissions[0].length, 1);
      expect(emissions[1].length, 2);
    });
  });
}
