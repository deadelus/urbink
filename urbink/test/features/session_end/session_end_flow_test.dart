import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';
import 'package:urbink/features/gamification/widgets/celebration_queue_listener.dart';
import 'package:urbink/features/session_end/controllers/session_end_flow.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/session_summary_sheet.dart';
import 'package:urbink/features/sessions/models/session_data.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _session = SessionData(active: false, km: 1.5, streets: 20, secs: 600);

const _badge1 = BadgeUnlock(id: 'b1', name: 'Badge A', description: 'D1', icon: '🏆');
const _badge2 = BadgeUnlock(id: 'b2', name: 'Badge B', description: 'D2', icon: '⭐');

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1100);
  tester.view.devicePixelRatio = 1.0;
}

/// App test avec ProviderScope + CelebrationQueueListener.
/// GoRouter non monté — context.go() lèvera une exception consommée par takeException().
Widget _flowApp(void Function(BuildContext ctx, WidgetRef ref) capture) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: Consumer(
        builder: (ctx, ref, _) {
          capture(ctx, ref);
          return CelebrationQueueListener(
            child: const Scaffold(body: Center(child: Text('map'))),
          );
        },
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionEndFlow', () {
    testWidgets('sans badges — affiche le SessionSummarySheet, queue reste vide',
        (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      late BuildContext ctx;
      late WidgetRef ref;
      await tester.pumpWidget(_flowApp((c, r) { ctx = c; ref = r; }));
      await tester.pumpAndSettle();

      SessionEndFlow.show(
          context: ctx, ref: ref, session: _session, badges: const []);
      await tester.pumpAndSettle();

      expect(find.byType(SessionSummarySheet), findsOneWidget);
      expect(ref.read(celebrationQueueProvider), isEmpty);
    });

    testWidgets('avec 2 badges — queue contient 2 events après Super!',
        (tester) async {
      _setTallViewport(tester);
      addTearDown(tester.view.resetPhysicalSize);

      late BuildContext ctx;
      late WidgetRef ref;
      await tester.pumpWidget(_flowApp((c, r) { ctx = c; ref = r; }));
      await tester.pumpAndSettle();

      SessionEndFlow.show(
          context: ctx,
          ref: ref,
          session: _session,
          badges: const [_badge1, _badge2],
          onNavigate: () {});
      await tester.pumpAndSettle();

      expect(find.byType(SessionSummarySheet), findsOneWidget);

      await tester.ensureVisible(find.text('Super !'));
      await tester.tap(find.text('Super !'));
      await tester.pumpAndSettle();

      final queue = ref.read(celebrationQueueProvider);
      expect(queue.length, 2);
      expect(queue[0].id, 'badge-b1');
      expect(queue[0].title, 'Badge A');
      expect(queue[1].id, 'badge-b2');
      expect(queue[1].title, 'Badge B');
    });
  });
}
