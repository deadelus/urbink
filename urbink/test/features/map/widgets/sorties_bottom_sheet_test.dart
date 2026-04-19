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
          body: Center(child: Text('Create itineraire')),
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

/// Open the sheet from PARTIAL to OPEN by dragging up from the bottom.
Future<void> _openSheet(WidgetTester tester) async {
  // The sheet is aligned to bottom and is 72px tall.
  // Drag up from near the bottom of the screen.
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final startPoint = Offset(size.width / 2, size.height - 36);
  await tester.dragFrom(startPoint, const Offset(0, -400));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests — 2-state bottom sheet (PARTIAL / OPEN) + Offstage when active
// ---------------------------------------------------------------------------

void main() {
  group('SortiesBottomSheet', () {
    // AC1 — sheet starts in PARTIAL state with hint visible
    testWidgets('AC1 — starts PARTIAL, hint visible', (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      // PARTIAL: hint visible
      expect(find.text('Démarrer une sortie'), findsOneWidget);
    });

    // AC2 — drag up opens OPEN with all content visible
    testWidgets('AC2 — drag up opens OPEN with cards and CTA',
        (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      await _openSheet(tester);

      expect(find.text('Circuit libre'), findsOneWidget);
      expect(find.text('Itinéraire'), findsOneWidget);
      expect(find.text('Démarrer la sortie'), findsOneWidget);
    });

    // AC3 — tap Itinéraire shows navigation view
    testWidgets('AC3 — tap Itinéraire shows nav view', (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      await _openSheet(tester);

      await tester.tap(find.text('Itinéraire'));
      await tester.pumpAndSettle();

      expect(find.text('Naviguer avec…'), findsOneWidget);
      expect(find.text('Retour'), findsOneWidget);
    });

    // AC3 — Retour goes back to select mode
    testWidgets('AC3 — Retour revient sur select mode', (tester) async {
      await tester.pumpWidget(_wrap(const SortiesBottomSheet()));
      await tester.pump();

      await _openSheet(tester);

      await tester.tap(find.text('Itinéraire'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retour'));
      await tester.pumpAndSettle();

      expect(find.text('Circuit libre'), findsOneWidget);
      expect(find.text('Démarrer la sortie'), findsOneWidget);
    });

    // AC4 — session active: sheet hidden via Offstage
    testWidgets('AC4 — session active: sheet hidden', (tester) async {
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

      // Content should not be visible when session active
      expect(find.text('Démarrer une sortie'), findsNothing);
    });

    // AC4 — session idle again: sheet reappears
    testWidgets('AC4 — retour idle reaffiche le hint', (tester) async {
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

      // Start: hint visible (PARTIAL)
      expect(find.text('Démarrer une sortie'), findsOneWidget);

      // Go active → sheet hidden
      container.read(sessionStateProvider.notifier).state = SessionState.active;
      await tester.pumpAndSettle();

      // Back to idle → sheet visible again
      container.read(sessionStateProvider.notifier).state = SessionState.idle;
      await tester.pumpAndSettle();

      expect(find.text('Démarrer une sortie'), findsOneWidget);
    });
  });
}
