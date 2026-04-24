import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/session_summary_sheet.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Enveloppe la sheet dans un MaterialApp avec viewport 400×1100 pour
/// que DraggableScrollableSheet (initialChildSize:0.55) affiche tout son contenu.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    builder: (ctx, widget) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
      child: widget!,
    ),
    home: Scaffold(body: child),
  );
}

/// Configure le viewport à 400×1100 px pour que le contenu soit visible.
void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1100);
  tester.view.devicePixelRatio = 1.0;
}

const _session = SessionData(
  active: false,
  km: 2.4,
  streets: 47,
  secs: 754, // 12:34
);

const _badge1 = BadgeUnlock(
  id: 'b1',
  name: 'Pont de la Tournelle',
  description: 'Description',
  icon: '🏆',
);

const _badge2 = BadgeUnlock(
  id: 'b2',
  name: 'Berge Sud',
  description: 'Description 2',
  icon: '🌊',
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionSummarySheet', () {
    tearDown(() {
      // Restaure le viewport par défaut après chaque test
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('affiche 4 stat cards avec les valeurs correctes', (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(
        SessionSummarySheet(
          session: _session,
          newBadges: const [],
          onClose: () {},
          onCelebrate: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('47'), findsOneWidget);
      expect(find.text('2.4'), findsOneWidget);
      expect(find.text('12:34'), findsOneWidget);
      // Stat card badges = 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('sans badges — bandeau non rendu', (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(
        SessionSummarySheet(
          session: _session,
          newBadges: const [],
          onClose: () {},
          onCelebrate: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Pas de chevron → pas de bandeau badges
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
    });

    testWidgets('avec 3 badges — bandeau affiche "3 badges débloqués !"',
        (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      const badge3 = BadgeUnlock(
        id: 'b3',
        name: 'Notre-Dame',
        description: 'D',
        icon: '⛪',
      );

      await tester.pumpWidget(_wrap(
        SessionSummarySheet(
          session: _session,
          newBadges: const [_badge1, _badge2, badge3],
          onClose: () {},
          onCelebrate: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3 badges débloqués !'), findsOneWidget);
    });

    testWidgets('tap "Super !" appelle onClose()', (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      var called = false;
      await tester.pumpWidget(_wrap(
        SessionSummarySheet(
          session: _session,
          newBadges: const [],
          onClose: () => called = true,
          onCelebrate: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Super !'));
      await tester.tap(find.text('Super !'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('tap bandeau badges appelle onCelebrate avec la liste',
        (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      List<BadgeUnlock>? received;
      await tester.pumpWidget(_wrap(
        SessionSummarySheet(
          session: _session,
          newBadges: const [_badge1, _badge2],
          onClose: () {},
          onCelebrate: (b) => received = b,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(Icons.chevron_left_rounded));
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
      expect(received!.length, equals(2));
    });
  });
}
