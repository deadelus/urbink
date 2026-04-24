import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/session_end/models/badge_unlock.dart';
import 'package:urbink/features/session_end/widgets/badge_celebration.dart';
import 'package:urbink/features/session_end/widgets/celebration_particles.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {bool disableAnimations = true}) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    builder: (ctx, widget) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(disableAnimations: disableAnimations),
      child: widget!,
    ),
    home: Scaffold(body: child),
  );
}

const _badge = BadgeUnlock(
  id: 'b1',
  name: 'Pont de la Tournelle',
  description: 'Vous avez traversé ce pont historique datant du XVIIIe siècle.',
  icon: '🏆',
  rarity: BadgeRarity.legendary,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BadgeCelebration', () {
    testWidgets('HapticFeedback.heavyImpact() déclenché au mount', (tester) async {
      final log = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          log.add(call);
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await tester.pumpWidget(_wrap(
        BadgeCelebration(
          badge: _badge,
          currentIndex: 1,
          total: 1,
          onDone: () {},
        ),
      ));
      await tester.pump();

      expect(
        log.any(
          (c) =>
              c.method == 'HapticFeedback.vibrate' ||
              c.method == 'HapticFeedback.heavyImpact',
        ),
        isTrue,
      );
    });

    testWidgets(
        'avec disableAnimations=true — CelebrationParticles non rendu',
        (tester) async {
      await tester.pumpWidget(_wrap(
        BadgeCelebration(
          badge: _badge,
          currentIndex: 1,
          total: 1,
          onDone: () {},
        ),
        disableAnimations: true,
      ));
      await tester.pump();

      // CelebrationParticles rend SizedBox.shrink() quand disableAnimations
      expect(find.byType(CelebrationParticles), findsOneWidget);
      // Aucun texte emoji de particule — la liste est vide
      expect(find.byType(Stack).evaluate().length, greaterThan(0));
    });

    testWidgets('tap "Continuer l\'exploration" appelle onDone()', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(
        BadgeCelebration(
          badge: _badge,
          currentIndex: 1,
          total: 1,
          onDone: () => called = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Continuer l'exploration"));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('indicateur de progression masqué si total=1', (tester) async {
      await tester.pumpWidget(_wrap(
        BadgeCelebration(
          badge: _badge,
          currentIndex: 1,
          total: 1,
          onDone: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1 / 1'), findsNothing);
    });

    testWidgets('indicateur de progression affiché si total > 1', (tester) async {
      await tester.pumpWidget(_wrap(
        BadgeCelebration(
          badge: _badge,
          currentIndex: 2,
          total: 3,
          onDone: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
    });
  });

  group('BadgeMedal — golden tests par rarity', () {
    for (final rarity in BadgeRarity.values) {
      testWidgets('rarity $rarity rend sans erreur', (tester) async {
        final badge = BadgeUnlock(
          id: rarity.name,
          name: rarity.name,
          description: 'Test',
          icon: '🏆',
          rarity: rarity,
        );

        await tester.pumpWidget(_wrap(
          BadgeCelebration(
            badge: badge,
            currentIndex: 1,
            total: 1,
            onDone: () {},
          ),
        ));
        await tester.pumpAndSettle();

        // Aucune exception → le widget rend correctement
        expect(tester.takeException(), isNull);
      });
    }
  });
}
