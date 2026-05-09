import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/quartier_badge.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/gamification/providers/badgeable_monuments_provider.dart';
import 'package:urbink/features/gamification/providers/monument_badges_provider.dart';
import 'package:urbink/features/gamification/providers/quartier_badges_provider.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';
import 'package:urbink/features/gamification/screens/challenges_screen.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _twoQuartiers = [
  const QuartierProgression(
    id: 'arrond_1',
    name: '1er',
    totalStreets: 100,
    exploredStreets: 50,
  ),
  const QuartierProgression(
    id: 'arrond_2',
    name: '2e',
    totalStreets: 200,
    exploredStreets: 20,
  ),
];

final _completedQuartier = [
  const QuartierProgression(
    id: 'arrond_1',
    name: '1er',
    totalStreets: 100,
    exploredStreets: 100,
  ),
];

final _badge = QuartierBadge(
  id: 'quartier_arrond_1',
  quartierId: 'arrond_1',
  name: '1er',
  secretLocal: 'Secret du 1er arrondissement.',
  unlockedAt: DateTime(2026, 4, 27),
);

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(
  Widget child, {
  List<Override> overrides = const [],
}) =>
    ProviderScope(
      overrides: [
        quartierBadgesStreamProvider
            .overrideWith((ref) => const Stream.empty()),
        badgeableMonumentsProvider
            .overrideWith((ref) async => const <Monument>[]),
        monumentBadgesStreamProvider
            .overrideWith((ref) => const Stream.empty()),
        ...overrides,
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: child,
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChallengesScreen', () {
    testWidgets('affiche un spinner pendant le chargement', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('affiche le titre Challenges et la section Quartiers',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_twoQuartiers),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Challenges'), findsOneWidget);
      expect(find.text('Quartiers'), findsOneWidget);
    });

    testWidgets('affiche un LinearProgressIndicator par quartier',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_twoQuartiers),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('affiche le nom et le % de chaque quartier', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_twoQuartiers),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('1er'), findsAtLeastNWidgets(1));
      expect(find.text('50.0%'), findsOneWidget);
      expect(find.text('2e'), findsOneWidget);
      expect(find.text('10.0%'), findsOneWidget);
    });

    testWidgets('affiche le compteur de rues', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_twoQuartiers),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('50 / 100 rues'), findsOneWidget);
      expect(find.text('20 / 200 rues'), findsOneWidget);
    });

    testWidgets('affiche un message en cas d\'erreur', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.error(Exception('Erreur test')),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('affiche tinte dorée pour un quartier complété à 100%',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_completedQuartier),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('100%'), findsOneWidget);
      expect(find.text('🏆'), findsAtLeastNWidgets(1));
    });

    testWidgets('affiche la section Badges Quartiers quand un badge existe',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_completedQuartier),
            ),
            quartierBadgesStreamProvider.overrideWith(
              (ref) => Stream.value([_badge]),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Badges Quartiers'), findsOneWidget);
    });

    testWidgets('affiche la section Monuments', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_twoQuartiers),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Monuments'), findsOneWidget);
    });

    testWidgets('masque la section Badges Quartiers si liste vide',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ChallengesScreen(),
          overrides: [
            quartiersProgressionProvider.overrideWith(
              (ref) => Stream.value(_twoQuartiers),
            ),
            quartierBadgesStreamProvider.overrideWith(
              (ref) => Stream.value(const []),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Badges Quartiers'), findsNothing);
    });
  });
}
