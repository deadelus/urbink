import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/gamification/providers/quartiers_progression_provider.dart';
import 'package:urbink/features/gamification/screens/challenges_screen.dart';

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

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
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

      expect(find.text('1er'), findsOneWidget);
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
  });
}
