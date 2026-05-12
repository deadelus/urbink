import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:urbink/features/parcours/data/parcours_model.dart';
import 'package:urbink/features/parcours/providers/parcours_generation_provider.dart';
import 'package:urbink/features/parcours/screens/parcours_screen.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _fakeParcours = Parcours(
  id: 'test-id',
  name: 'Circuit 30 min à pied',
  points: const [
    LatLng(48.8566, 2.3522),
    LatLng(48.8580, 2.3540),
    LatLng(48.8600, 2.3560),
    LatLng(48.8566, 2.3522),
  ],
  estimatedDistance: 2490,
  estimatedDuration: 1800,
  mode: TransportMode.walking,
  type: ParcoursType.auto,
  createdAt: DateTime(2026, 5, 12),
);

/// Stub notifier — état contrôlé depuis les tests sans dépendances Firebase.
class _StubNotifier extends ParcoursGenerationNotifier {
  _StubNotifier(super.initialState) : super.forTest();

  @override
  Future<void> generate({
    required String uid,
    required double lat,
    required double lng,
    required int durationMinutes,
    required TransportMode mode,
  }) async {}

  @override
  Future<String?> saveParcours({
    required String uid,
    required Parcours parcours,
  }) async => 'fake-id';
}

Widget _wrap(Widget child, {required ParcoursGenerationState genState}) =>
    ProviderScope(
      overrides: [
        currentUidProvider.overrideWithValue('uid-test'),
        lastKnownPositionProvider.overrideWith(
          (ref) async => (48.8566, 2.3522),
        ),
        parcoursGenerationNotifierProvider.overrideWith(
          (ref) => _StubNotifier(genState),
        ),
      ],
      child: MaterialApp(home: child),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ParcoursScreen — état idle', () {
    testWidgets('affiche le titre et les sélecteurs de durée', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: const ParcoursGenerationIdle()),
      );
      await tester.pump();

      expect(find.text('Parcours'), findsAtLeast(1));
      expect(find.text('Parcours automatique'), findsOneWidget);
      expect(find.byKey(const Key('duration_15')), findsOneWidget);
      expect(find.byKey(const Key('duration_30')), findsOneWidget);
      expect(find.byKey(const Key('duration_45')), findsOneWidget);
      expect(find.byKey(const Key('duration_60')), findsOneWidget);
    });

    testWidgets('affiche les sélecteurs de mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: const ParcoursGenerationIdle()),
      );
      await tester.pump();

      expect(find.byKey(const Key('mode_walking')), findsOneWidget);
      expect(find.byKey(const Key('mode_cycling')), findsOneWidget);
      expect(find.byKey(const Key('mode_driving')), findsOneWidget);
    });

    testWidgets('bouton Générer présent et actif', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: const ParcoursGenerationIdle()),
      );
      await tester.pump();

      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('generate_button')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('pas de carte ni bouton Démarrer à l\'état idle', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: const ParcoursGenerationIdle()),
      );
      await tester.pump();

      expect(find.byKey(const Key('result_preview')), findsNothing);
      expect(find.byKey(const Key('demarrer_button')), findsNothing);
    });

    testWidgets('sélection d\'une durée met à jour le chip actif', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: const ParcoursGenerationIdle()),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('duration_15')));
      await tester.pump();

      final chip = tester.widget<ChoiceChip>(
        find.byKey(const Key('duration_15')),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('sélection du mode vélo met à jour le chip actif', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: const ParcoursGenerationIdle()),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('mode_cycling')));
      await tester.pump();

      final chip = tester.widget<ChoiceChip>(
        find.byKey(const Key('mode_cycling')),
      );
      expect(chip.selected, isTrue);
    });
  });

  group('ParcoursScreen — état loading', () {
    testWidgets('bouton Générer désactivé', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParcoursScreen(),
          genState: const ParcoursGenerationLoading(),
        ),
      );
      await tester.pump();

      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('generate_button')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('message de génération visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParcoursScreen(),
          genState: const ParcoursGenerationLoading(),
        ),
      );
      await tester.pump();

      expect(find.text('Génération en cours…'), findsOneWidget);
    });
  });

  group('ParcoursScreen — état success', () {
    final successState = ParcoursGenerationSuccess(
      parcours: _fakeParcours,
      newStreetsCount: 12,
    );

    testWidgets('affiche RouteMapPreview variant medium', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: successState),
      );
      await tester.pump();

      expect(find.byKey(const Key('result_preview')), findsOneWidget);
    });

    testWidgets('affiche la distance estimée', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: successState),
      );
      await tester.pump();

      // 2490m → 2.5 km
      expect(find.text('2.5 km'), findsOneWidget);
    });

    testWidgets('affiche le nombre de nouvelles rues', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: successState),
      );
      await tester.pump();

      expect(find.text('12 rues'), findsOneWidget);
    });

    testWidgets('bouton Démarrer ce parcours visible et actif', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParcoursScreen(), genState: successState),
      );
      await tester.pump();

      final btn = find.byKey(const Key('demarrer_button'));
      expect(btn, findsOneWidget);
      expect(find.text('Démarrer ce parcours'), findsOneWidget);
      final widget = tester.widget<FilledButton>(btn);
      expect(widget.onPressed, isNotNull);
    });
  });

  group('ParcoursScreen — état error', () {
    const errorMsg =
        "Impossible de générer un parcours pour l'instant, réessaie dans quelques instants";

    testWidgets('affiche la carte d\'erreur', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParcoursScreen(),
          genState: const ParcoursGenerationError(message: errorMsg),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('error_card')), findsOneWidget);
      expect(find.text(errorMsg), findsOneWidget);
    });

    testWidgets('bouton Générer toujours actif après une erreur', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParcoursScreen(),
          genState: const ParcoursGenerationError(message: 'Erreur'),
        ),
      );
      await tester.pump();

      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('generate_button')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('pas de carte résultat en état erreur', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParcoursScreen(),
          genState: const ParcoursGenerationError(message: 'Erreur'),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('result_preview')), findsNothing);
    });
  });
}
