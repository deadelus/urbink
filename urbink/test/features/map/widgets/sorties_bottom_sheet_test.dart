import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:urbink/features/map/widgets/sorties_bottom_sheet.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, s) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/create-itineraire',
        builder: (_, s) => const Scaffold(
          body: Center(child: Text('Créer un itinéraire')),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SortiesBottomSheet', () {
    // AC1 — sheet se construit avec les éléments collapsed visibles
    testWidgets('AC1 — affiche le handle et le hint en état collapsed',
        (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      expect(find.text('↑ Dérouler pour démarrer une sortie'), findsOneWidget);
    });

    // AC2 — contenu peek visible : cards + chip + bouton Démarrer
    testWidgets('AC2 — affiche les cards et le bouton Démarrer après drag',
        (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      // Fling vers le haut — vélocité négative déclenche onSnapUp() → animateTo(peekSize)
      await tester.fling(
        find.text('↑ Dérouler pour démarrer une sortie'),
        const Offset(0, -200),
        800,
      );
      await tester.pumpAndSettle();

      expect(find.text('Circuit libre'), findsOneWidget);
      expect(find.text('Itinéraire'), findsOneWidget);
      expect(find.text('▶ Démarrer la sortie'), findsOneWidget);
      expect(find.text('Mode auto-détecté · GPS prêt'), findsOneWidget);
    });

    // AC3 — tap card Itinéraire → vue liste (AnimatedSwitcher)
    testWidgets('AC3 — tap Itinéraire affiche la vue liste', (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      // Ouvrir le sheet
      await tester.fling(
        find.text('↑ Dérouler pour démarrer une sortie'),
        const Offset(0, -200),
        800,
      );
      await tester.pumpAndSettle();

      // Tap card Itinéraire
      await tester.tap(find.text('Itinéraire'));
      await tester.pumpAndSettle();

      expect(find.text('Mes itinéraires'), findsOneWidget);
      expect(find.text('Retour'), findsOneWidget);
      expect(find.text('Créer'), findsOneWidget);
      // La vue sélection est masquée
      expect(find.text('Circuit libre'), findsNothing);
    });

    // AC3 — bouton Retour revient sur la vue sélection
    testWidgets('AC3 — bouton Retour revient sur la vue select mode',
        (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      await tester.fling(
        find.text('↑ Dérouler pour démarrer une sortie'),
        const Offset(0, -200),
        800,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Itinéraire'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retour'));
      await tester.pumpAndSettle();

      expect(find.text('Circuit libre'), findsOneWidget);
      expect(find.text('▶ Démarrer la sortie'), findsOneWidget);
    });

    // AC4 — session active : sheet non déroulable, contenu masqué
    testWidgets('AC4 — session active : hint masqué, sheet locked',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SortiesBottomSheet(),
          overrides: [
            sessionStateProvider
                .overrideWith((ref) => SessionState.active),
          ],
        ),
      );
      await tester.pump();

      // Le hint n'est pas visible (session active → collapsed locked)
      expect(find.text('↑ Dérouler pour démarrer une sortie'), findsNothing);
      // Les cards de sélection ne sont pas visibles
      expect(find.text('Circuit libre'), findsNothing);
      expect(find.text('▶ Démarrer la sortie'), findsNothing);
    });

    // AC4 — session passe de active à idle → hint réapparaît
    testWidgets('AC4 — retour à idle réaffiche le hint', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, s) => const Scaffold(
              body: SortiesBottomSheet(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      // Passer à active
      container.read(sessionStateProvider.notifier).state = SessionState.active;
      await tester.pumpAndSettle();

      expect(find.text('↑ Dérouler pour démarrer une sortie'), findsNothing);

      // Repasser à idle
      container.read(sessionStateProvider.notifier).state = SessionState.idle;
      await tester.pumpAndSettle();

      expect(find.text('↑ Dérouler pour démarrer une sortie'), findsOneWidget);
    });
  });
}
