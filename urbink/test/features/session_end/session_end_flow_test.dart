import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/session_end/controllers/session_end_flow.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/badge_celebration.dart';
import 'package:urbink/features/session_end/widgets/session_summary_sheet.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _session = SessionData(active: false, km: 1.5, streets: 20, secs: 600);

const _badge1 = BadgeUnlock(
    id: 'b1', name: 'Badge A', description: 'D1', icon: '🏆');
const _badge2 = BadgeUnlock(
    id: 'b2', name: 'Badge B', description: 'D2', icon: '⭐');

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1100);
  tester.view.devicePixelRatio = 1.0;
}

/// Crée une app avec un bouton qui lance le flow.
/// GoRouter n'est pas monté — le test s'arrête avant l'appel context.go().
Widget _flowApp(BuildContext Function(BuildContext) ctxCapture) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: Builder(
      builder: (ctx) {
        ctxCapture(ctx);
        return const Scaffold(
          body: Center(child: Text('map')),
        );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionEndFlow', () {
    testWidgets('sans badges — affiche le SessionSummarySheet', (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      late BuildContext ctx;
      await tester.pumpWidget(_flowApp((c) => ctx = c));
      await tester.pumpAndSettle();

      // Lance le flow sans await pour que le test puisse inspecter l'UI
      SessionEndFlow.show(context: ctx, session: _session, badges: const []);
      await tester.pumpAndSettle();

      expect(find.byType(SessionSummarySheet), findsOneWidget);
      expect(find.byType(BadgeCelebration), findsNothing);
    });

    testWidgets('avec 2 badges — sheet visible, puis 2 célébrations enchaînées',
        (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      late BuildContext ctx;
      await tester.pumpWidget(_flowApp((c) => ctx = c));
      await tester.pumpAndSettle();

      SessionEndFlow.show(
          context: ctx, session: _session, badges: const [_badge1, _badge2]);
      await tester.pumpAndSettle();

      // Sheet visible
      expect(find.byType(SessionSummarySheet), findsOneWidget);

      // Scroll pour afficher "Super !" si nécessaire
      await tester.ensureVisible(find.text('Super !'));
      await tester.tap(find.text('Super !'));
      // Plusieurs pump nécessaires : dismiss modal → microtask → show() continue → showGeneralDialog
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();

      // Première célébration
      expect(find.byType(BadgeCelebration), findsOneWidget);
      expect(find.text('Badge A'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);

      // Continue vers badge 2 — 6×100ms pour couvrir exit anim (250ms) + délai inter-badges (200ms)
      // badge 2 apparaît à ~600ms, pumpAndSettle() seul reviendrait à ~400ms (no frames)
      await tester.tap(find.text("Continuer l'exploration"));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Deuxième célébration
      expect(find.byType(BadgeCelebration), findsOneWidget);
      expect(find.text('Badge B'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);
    });
  });
}
