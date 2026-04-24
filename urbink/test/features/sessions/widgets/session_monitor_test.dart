import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/features/sessions/widgets/session_monitor.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    // Désactive les animations pour éviter les boucles infinies (PulseDot).
    builder: (context, widget) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: widget!,
    ),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

const _baseSession = SessionData(
  active: true,
  km: 1.0,
  streets: 10,
  secs: 100,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionMonitor', () {
    testWidgets('timer formate secs=754 en 12:34', (tester) async {
      await tester.pumpWidget(_wrap(
        SessionMonitor(
          session: const SessionData(
            active: true,
            km: 1.0,
            streets: 10,
            secs: 754,
          ),
          mode: 'libre',
          expanded: false,
          onStop: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('12:34'), findsOneWidget);
    });

    testWidgets('allure formate km=2.45 secs=1800 en 12\'15"', (tester) async {
      await tester.pumpWidget(_wrap(
        SessionMonitor(
          session: const SessionData(
            active: true,
            km: 2.45,
            streets: 47,
            secs: 1800,
          ),
          mode: 'libre',
          expanded: false,
          onStop: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text("12'15\""), findsOneWidget);
    });

    testWidgets('tap bouton stop appelle onStop une fois', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(_wrap(
        SessionMonitor(
          session: _baseSession,
          mode: 'libre',
          expanded: false,
          onStop: () => callCount++,
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('session_monitor_stop_button')));
      await tester.pump();
      expect(callCount, 1);
    });

    testWidgets('expanded=false masque la section progression et l\'astuce',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SessionMonitor(
          session: _baseSession,
          mode: 'libre',
          expanded: false,
          onStop: () {},
          tipText: 'Test astuce',
        ),
      ));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('session_monitor_progress_section')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_monitor_tip_card')),
        findsNothing,
      );
    });

    testWidgets('expanded=true affiche la section progression avec le bon %',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SessionMonitor(
          session: const SessionData(
            active: true,
            km: 2.45,
            streets: 47,
            secs: 754,
            zonePercent: 68,
            newStreets: 35,
            calories: 159,
          ),
          mode: 'libre',
          expanded: true,
          onStop: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('session_monitor_progress_section')),
        findsOneWidget,
      );
      expect(find.text('68%'), findsOneWidget);
    });
  });
}
