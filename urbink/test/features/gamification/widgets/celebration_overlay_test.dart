import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/models/celebration_event.dart';
import 'package:urbink/features/gamification/providers/celebration_queue_provider.dart';
import 'package:urbink/features/gamification/widgets/celebration_overlay.dart';
import 'package:urbink/features/gamification/widgets/celebration_queue_listener.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _app({required ProviderContainer container, required Widget child}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        builder: (ctx, c) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: c!,
        ),
        home: child,
      ),
    );

Widget _overlayApp(
  ProviderContainer container,
  CelebrationEvent event, {
  VoidCallback? onDone,
}) =>
    _app(
      container: container,
      child: Scaffold(
        body: CelebrationOverlay(
          event: event,
          onDone: onDone ?? () {},
        ),
      ),
    );

Widget _queueApp(ProviderContainer container) => _app(
      container: container,
      child: const CelebrationQueueListener(
        child: Scaffold(body: Text('carte')),
      ),
    );

// ---------------------------------------------------------------------------
// Tests — CelebrationOverlay
// ---------------------------------------------------------------------------

void main() {
  group('CelebrationOverlay — mode badge', () {
    const event = CelebrationEvent(
      id: 'badge-eiffel',
      mode: CelebrationMode.badge,
      title: 'Tour Eiffel',
      subtitle: 'Premier monument visité',
      iconEmoji: '🗼',
    );

    testWidgets('affiche le titre et le bouton Continuer', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await tester.pumpWidget(_overlayApp(c, event));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tour Eiffel'), findsOneWidget);
      expect(find.text('Premier monument visité'), findsOneWidget);
      expect(find.text('🗼'), findsOneWidget);
      expect(find.textContaining("l'exploration"), findsOneWidget);
    });

    testWidgets('onDone appelé au tap sur le bouton Continuer', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      bool done = false;
      await tester.pumpWidget(_overlayApp(c, event, onDone: () => done = true));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining("l'exploration"));
      await tester.pumpAndSettle();

      expect(done, isTrue);
    });

    testWidgets('sans subtitle — pas de carte secret', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      const noSub = CelebrationEvent(
          id: 'x', mode: CelebrationMode.badge, title: 'Mon Badge');
      await tester.pumpWidget(_overlayApp(c, noSub));
      await tester.pumpAndSettle();

      expect(find.text('🗝️'), findsNothing);
    });
  });

  group('CelebrationOverlay — mode district', () {
    const event = CelebrationEvent(
      id: 'district-marais',
      mode: CelebrationMode.district,
      title: 'Le Marais',
      subtitle: 'La fontaine cachée rue de Bretagne',
    );

    testWidgets('affiche le secret local et le bouton Continuer', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await tester.pumpWidget(_overlayApp(c, event));
      await tester.pumpAndSettle();

      expect(find.text('La fontaine cachée rue de Bretagne'), findsOneWidget);
      expect(find.text('🗝️'), findsOneWidget);
      expect(find.textContaining("l'exploration"), findsOneWidget);
    });

    testWidgets('bouton Partager absent si onShare est null', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await tester.pumpWidget(_overlayApp(c, event));
      await tester.pumpAndSettle();

      expect(find.text('Partager'), findsNothing);
    });

    testWidgets('bouton Partager présent si onShare fourni', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final eventWithShare = CelebrationEvent(
        id: 'district-marais',
        mode: CelebrationMode.district,
        title: 'Le Marais',
        subtitle: 'Secret',
        onShare: () {},
      );
      await tester.pumpWidget(_overlayApp(c, eventWithShare));
      await tester.pumpAndSettle();

      expect(find.text('Partager'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Tests — CelebrationQueueListener
  // ---------------------------------------------------------------------------

  group('CelebrationQueueListener', () {
    testWidgets('affiche CelebrationOverlay quand queue non vide',
        (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await tester.pumpWidget(_queueApp(c));
      await tester.pumpAndSettle();

      c.read(celebrationQueueProvider.notifier).push(
            const CelebrationEvent(
                id: 'badge-test',
                mode: CelebrationMode.badge,
                title: 'Mon Badge'),
          );
      // pump #1 : Riverpod notifie le listener → addPostFrameCallback enregistré
      // pump #2 : post-frame callback → showGeneralDialog → route poussée
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(CelebrationOverlay), findsOneWidget);
      expect(find.textContaining('Mon Badge'), findsOneWidget);
    });

    testWidgets("pop la queue après dismiss de l'overlay", (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await tester.pumpWidget(_queueApp(c));
      await tester.pumpAndSettle();

      c.read(celebrationQueueProvider.notifier).push(
            const CelebrationEvent(
                id: 'badge-test',
                mode: CelebrationMode.badge,
                title: 'Mon Badge'),
          );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(CelebrationOverlay), findsOneWidget);

      await tester.tap(find.textContaining("l'exploration"));
      await tester.pumpAndSettle();

      expect(c.read(celebrationQueueProvider), isEmpty);
      expect(find.byType(CelebrationOverlay), findsNothing);
    });
  });
}
