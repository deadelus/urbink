import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';
import 'package:urbink/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MonumentCollection _col({
  required String id,
  required List<bool> locked,
}) {
  return MonumentCollection(
    id: id,
    name: 'Col $id',
    subtitle: 'Sub',
    icon: '⭐',
    color: Colors.amber,
    monuments: [
      for (int i = 0; i < locked.length; i++)
        CollectionMonument(
          id: 'mon-$i',
          emoji: '🏛️',
          name: 'M$i',
          locked: locked[i],
        ),
    ],
  );
}

/// Provider override qui expose une liste modifiable de collections.
final _testCollectionsProvider =
    StateProvider<List<MonumentCollection>>((ref) => []);

// ---------------------------------------------------------------------------
// Widget minimaliste qui écoute collectionsProvider et pousse des celebrations
// Reproduit la logique de _BadgesScreenState.initState
// ---------------------------------------------------------------------------

class _TestListener extends ConsumerStatefulWidget {
  const _TestListener();

  @override
  ConsumerState<_TestListener> createState() => _TestListenerState();
}

class _TestListenerState extends ConsumerState<_TestListener> {
  final Set<String> _celebrated = {};

  @override
  void initState() {
    super.initState();
    ref.listenManual(_testCollectionsProvider, (prev, next) {
      if (prev == null) return;
      for (final col in next) {
        if (col.stats.pct == 100 && !_celebrated.contains(col.id)) {
          _celebrated.add(col.id);
          ref.read(celebrationQueueProvider.notifier).push(
                CelebrationEvent(
                  id: 'collection-${col.id}',
                  mode: CelebrationMode.badge,
                  title: col.name,
                  iconEmoji: col.icon,
                ),
              );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Listener complétion collection 100%', () {
    testWidgets(
        'pas de celebration au chargement initial même si collections complètes',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          _testCollectionsProvider.overrideWith(
              (ref) => [_col(id: 'a', locked: [false, false])]),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(body: _TestListener()),
          ),
        ),
      );
      await tester.pump();
      final queue = container.read(celebrationQueueProvider);
      expect(queue, isEmpty);
    });

    testWidgets('une celebration est poussée quand une collection passe à 100%',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          _testCollectionsProvider.overrideWith(
              (ref) => [_col(id: 'a', locked: [true, false])]),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(body: _TestListener()),
          ),
        ),
      );
      await tester.pump();

      // Simule le passage à 100% (tous débloqués)
      container.read(_testCollectionsProvider.notifier).state = [
        _col(id: 'a', locked: [false, false]),
      ];
      await tester.pump();

      final queue = container.read(celebrationQueueProvider);
      expect(queue.length, 1);
      expect(queue.first.id, 'collection-a');
      expect(queue.first.mode, CelebrationMode.badge);
    });

    testWidgets('pas de double celebration pour la même collection',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          _testCollectionsProvider.overrideWith(
              (ref) => [_col(id: 'b', locked: [true])]),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(body: _TestListener()),
          ),
        ),
      );
      await tester.pump();

      // Passe à 100%
      container.read(_testCollectionsProvider.notifier).state = [
        _col(id: 'b', locked: [false]),
      ];
      await tester.pump();

      // Re-trigger avec la même valeur
      container.read(_testCollectionsProvider.notifier).state = [
        _col(id: 'b', locked: [false]),
      ];
      await tester.pump();

      // Celebration queue popped par le listener interne — on vérifie via le
      // celebrationQueueProvider qu'il n'y a pas eu doublon
      final queue = container.read(celebrationQueueProvider);
      expect(queue.length, lessThanOrEqualTo(1));
    });
  });
}
