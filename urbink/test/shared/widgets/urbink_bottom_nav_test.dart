import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/theme/app_theme.dart';
import 'package:urbink/shared/widgets/urbink_bottom_nav.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget wrap(
  Widget child, {
  MediaQueryData? mediaQuery,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          final baseMediaQuery = MediaQuery.of(context);
          final effectiveMediaQuery = mediaQuery == null
              ? baseMediaQuery
              : baseMediaQuery.copyWith(
                  disableAnimations: mediaQuery.disableAnimations,
                  padding: mediaQuery.padding,
                  textScaler: mediaQuery.textScaler,
                );

          return MediaQuery(
            data: effectiveMediaQuery,
            child: Scaffold(body: child),
          );
        },
      ),
    ),
  );
}

UrbinkBottomNav buildNav({
  int currentIndex = 0,
  SessionState sessionState = SessionState.idle,
  void Function(int)? onTabSelected,
}) {
  return UrbinkBottomNav(
    currentIndex: currentIndex,
    sessionState: sessionState,
    onTabSelected: onTabSelected ?? (_) {},
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('UrbinkBottomNav v4 — Semantics VoiceOver', () {
    testWidgets('5 onglets ont chacun un label Semantics correct', (tester) async {
      await tester.pumpWidget(wrap(buildNav(currentIndex: 0)));

      expect(
        find.bySemanticsLabel(RegExp(r'Carte, onglet 1 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Parcours, onglet 2 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Social, onglet 3 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Badges, onglet 4 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Profil, onglet 5 sur 5')),
        findsOneWidget,
      );
    });

    testWidgets('aucun bouton central / Démarrer', (tester) async {
      await tester.pumpWidget(wrap(buildNav()));
      // v4 : le bouton central a été supprimé
      expect(find.bySemanticsLabel(RegExp(r'Démarrer')), findsNothing);
    });
  });

  group('UrbinkBottomNav v4 — Réduire les animations', () {
    testWidgets('AnimatedOpacity présent sur underline quand disableAnimations=true',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(currentIndex: 0),
          mediaQuery: const MediaQueryData(disableAnimations: true),
        ),
      );
      final underlineFinder = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedOpacity &&
            widget.child is Container &&
            (widget.child as Container).decoration is BoxDecoration &&
            ((widget.child as Container).decoration as BoxDecoration)
                    .borderRadius !=
                null,
        description: "AnimatedOpacity utilisé pour l'underline",
      );
      expect(underlineFinder, findsWidgets);
    });

    testWidgets('AnimatedContainer présent sur underline quand disableAnimations=false',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(currentIndex: 0),
          mediaQuery: const MediaQueryData(disableAnimations: false),
        ),
      );
      // 5 onglets → 5 AnimatedContainer (un indicateur par onglet)
      final underlineFinder = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.rectangle,
        description: "AnimatedContainer utilisé pour l'underline",
      );
      expect(underlineFinder, findsNWidgets(5));
    });

    testWidgets('5 AnimatedSwitcher — un par icône d\'onglet (pas de bouton central)', (tester) async {
      await tester.pumpWidget(wrap(buildNav()));
      // Chaque onglet a un AnimatedSwitcher pour la transition d'icône (couleur active/inactive)
      expect(find.byType(AnimatedSwitcher), findsNWidgets(5));
    });
  });

  group('UrbinkBottomNav v4 — Dynamic Type', () {
    testWidgets('aucun overflow avec Dynamic Type xxxLarge', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(),
          mediaQuery: const MediaQueryData(
            size: Size(375, 812),
            textScaler: TextScaler.linear(3.0),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('les labels onglets ont maxLines:1 et overflow ellipsis', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(),
          mediaQuery: const MediaQueryData(
            textScaler: TextScaler.linear(3.0),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      const labels = ['Carte', 'Parcours', 'Social', 'Badges', 'Profil'];
      final textWidgets = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(UrbinkBottomNav),
          matching: find.byType(Text),
        ),
      );
      final labelTexts =
          textWidgets.where((t) => labels.contains(t.data)).toList();

      expect(labelTexts, hasLength(labels.length));
      for (final text in labelTexts) {
        expect(text.maxLines, 1,
            reason: '${text.data} doit être limité à une ligne');
        expect(text.overflow, TextOverflow.ellipsis,
            reason: '${text.data} doit utiliser ellipsis');
      }
    });
  });

  group('UrbinkBottomNav v4 — Touch targets ≥ 44pt', () {
    testWidgets('tap sur onglet Carte déclenche onTabSelected(0)', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(buildNav(onTabSelected: (i) => tapped = i)),
      );

      await tester.tap(find.bySemanticsLabel(RegExp(r'Carte, onglet 1 sur 5')));
      await tester.pump();
      expect(tapped, 0);
    });

    testWidgets('tap sur onglet Parcours déclenche onTabSelected(1)', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(buildNav(onTabSelected: (i) => tapped = i)),
      );

      await tester.tap(find.bySemanticsLabel(RegExp(r'Parcours, onglet 2 sur 5')));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('tap sur onglet Profil déclenche onTabSelected(4)', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(buildNav(onTabSelected: (i) => tapped = i)),
      );

      await tester.tap(find.bySemanticsLabel(RegExp(r'Profil, onglet 5 sur 5')));
      await tester.pump();
      expect(tapped, 4);
    });
  });

  group('UrbinkBottomNav v4 — Safe areas iOS', () {
    testWidgets('hauteur inclut le padding bottom de la safe area', (tester) async {
      const bottomPadding = 34.0; // iPhone 15 home indicator

      await tester.pumpWidget(
        wrap(
          buildNav(),
          mediaQuery: const MediaQueryData(
            padding: EdgeInsets.only(bottom: bottomPadding),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(UrbinkBottomNav),
          matching: find.byType(Container).first,
        ),
      );

      expect(
        (container.constraints?.maxHeight ?? 0),
        greaterThanOrEqualTo(UrbinkSpacing.bottomNavHeight + bottomPadding),
      );
    });

    testWidgets('rendu correct sans padding (iPhone SE)', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(),
          mediaQuery: const MediaQueryData(padding: EdgeInsets.zero),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('UrbinkBottomNav v4 — Couleurs session', () {
    testWidgets('indicateur Ocre au repos (sessionState idle)', (tester) async {
      await tester.pumpWidget(
        wrap(buildNav(currentIndex: 0, sessionState: SessionState.idle)),
      );
      // L'indicateur actif doit exister (onglet 0 = Carte actif)
      final indicator = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == UrbinkColors.primary,
        description: 'indicateur Ocre #B8832E',
      );
      expect(indicator, findsWidgets);
    });

    testWidgets('indicateur Terra Cotta en session active', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(currentIndex: 0, sessionState: SessionState.active),
          mediaQuery: const MediaQueryData(disableAnimations: false),
        ),
      );
      final indicator = find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == UrbinkColors.primary,
        description: 'indicateur Deep Green #256F4C',
      );
      expect(indicator, findsWidgets);
    });
  });
}
