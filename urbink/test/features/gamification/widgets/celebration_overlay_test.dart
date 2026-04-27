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

Widget _app({required Widget child}) => ProviderScope(
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

Widget _overlayApp(CelebrationEvent event, {VoidCallback? onDone}) => _app(
      child: Scaffold(
        body: Builder(
          builder: (ctx) => CelebrationOverlay(
            event: event,
            onDone: onDone ?? () {},
          ),
        ),
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
      await tester.pumpWidget(_overlayApp(event));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tour Eiffel'), findsOneWidget);
      expect(find.text('Premier monument visité'), findsOneWidget);
      expect(find.text('🗼'), findsOneWidget);
      expect(find.textContaining("l'exploration"), findsOneWidget);
    });

    testWidgets('onDone appelé au tap sur le bouton Continuer', (tester) async {
      bool done = false;
      await tester.pumpWidget(_overlayApp(event, onDone: () => done = true));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining("l'exploration"));
      await tester.pumpAndSettle();

      expect(done, isTrue);
    });

    testWidgets('sans subtitle — pas de carte secret', (tester) async {
      const noSub = CelebrationEvent(
          id: 'x', mode: CelebrationMode.badge, title: 'Mon Badge');
      await tester.pumpWidget(_overlayApp(noSub));
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
      await tester.pumpWidget(_overlayApp(event));
      await tester.pumpAndSettle();

      expect(find.text('La fontaine cachée rue de Bretagne'), findsOneWidget);
      expect(find.text('🗝️'), findsOneWidget);
      expect(find.textContaining("l'exploration"), findsOneWidget);
    });

    testWidgets('bouton Partager absent si onShare est null', (tester) async {
      await tester.pumpWidget(_overlayApp(event));
      await tester.pumpAndSettle();

      expect(find.text('Partager'), findsNothing);
    });

    testWidgets('bouton Partager présent si onShare fourni', (tester) async {
      final eventWithShare = CelebrationEvent(
        id: 'district-marais',
        mode: CelebrationMode.district,
        title: 'Le Marais',
        subtitle: 'Secret',
        onShare: () {},
      );
      await tester.pumpWidget(_overlayApp(eventWithShare));
      await tester.pumpAndSettle();

      expect(find.text('Partager'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Tests — CelebrationQueueListener
  // ---------------------------------------------------------------------------

  group('CelebrationQueueListener', () {
    testWidgets('affiche CelebrationOverlay quand queue non vide', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(ProviderScope(
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
              capturedRef = ref;
              return CelebrationQueueListener(
                child: const Scaffold(body: Text('carte')),
              );
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      capturedRef.read(celebrationQueueProvider.notifier).push(
            const CelebrationEvent(
                id: 'badge-test',
                mode: CelebrationMode.badge,
                title: 'Mon Badge'),
          );
      // pump #1 : Riverpod notifie le listener → addPostFrameCallback enregistré
      // pump #2 : post-frame callback → showGeneralDialog → route poussée
      // pump #3+ : dialog rendu
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(CelebrationOverlay), findsOneWidget);
      expect(find.textContaining('Mon Badge'), findsOneWidget);
    });

    testWidgets('pop la queue après dismiss de l\'overlay', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(ProviderScope(
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
              capturedRef = ref;
              return CelebrationQueueListener(
                child: const Scaffold(body: Text('carte')),
              );
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      capturedRef.read(celebrationQueueProvider.notifier).push(
            const CelebrationEvent(
                id: 'badge-test',
                mode: CelebrationMode.badge,
                title: 'Mon Badge'),
          );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(CelebrationOverlay), findsOneWidget);

      // Dismiss via bouton Continuer
      await tester.tap(find.textContaining("l'exploration"));
      await tester.pumpAndSettle();

      expect(capturedRef.read(celebrationQueueProvider), isEmpty);
      expect(find.byType(CelebrationOverlay), findsNothing);
    });
  });
}
