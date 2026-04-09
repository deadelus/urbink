import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:urbink/shared/theme/app_theme.dart';
import 'package:urbink/shared/constants/spacing.dart';
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
  group('UrbinkBottomNav — Semantics VoiceOver (AC1)', () {
    testWidgets('chaque onglet a un label Semantics en français', (tester) async {
      await tester.pumpWidget(wrap(buildNav(currentIndex: 0)));

      expect(
        find.bySemanticsLabel(RegExp(r'Accueil, onglet 1 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Carte, onglet 2 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Challenges, onglet 4 sur 5')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Vous, onglet 5 sur 5')),
        findsOneWidget,
      );
    });

    testWidgets('bouton Démarrer idle annonce "Démarrer, onglet 3 sur 5"', (tester) async {
      await tester.pumpWidget(wrap(buildNav()));
      expect(
        find.bySemanticsLabel('Démarrer, onglet 3 sur 5'),
        findsOneWidget,
      );
    });

    testWidgets('bouton actif annonce "Pause session, onglet 3 sur 5"', (tester) async {
      await tester.pumpWidget(
        wrap(buildNav(sessionState: SessionState.active)),
      );
      expect(
        find.bySemanticsLabel('Pause session, onglet 3 sur 5'),
        findsOneWidget,
      );
    });

    testWidgets('bouton paused annonce "Reprendre session, onglet 3 sur 5"', (tester) async {
      await tester.pumpWidget(
        wrap(buildNav(sessionState: SessionState.paused)),
      );
      expect(
        find.bySemanticsLabel('Reprendre session, onglet 3 sur 5'),
        findsOneWidget,
      );
    });
  });

  group('UrbinkBottomNav — Réduire les animations (AC2)', () {
    testWidgets('AnimatedOpacity présent sur underline quand disableAnimations=true',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(currentIndex: 0),
          mediaQuery: const MediaQueryData(disableAnimations: true),
        ),
      );
      // Avec disableAnimations, on utilise AnimatedOpacity (pas AnimatedContainer pour l'underline)
      expect(find.byType(AnimatedOpacity), findsWidgets);
    });

    testWidgets('AnimatedContainer présent sur underline quand disableAnimations=false',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(currentIndex: 0),
          mediaQuery: const MediaQueryData(disableAnimations: false),
        ),
      );
      // Avec animations normales, les underlines sont des AnimatedContainer
      // à décoration rectangulaire (vs le bouton central qui est BoxShape.circle).
      // Il y en a exactement 4 (un par onglet non-central).
      final underlineFinder = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.rectangle,
        description: "AnimatedContainer utilisé pour l'underline",
      );
      expect(underlineFinder, findsNWidgets(4));
    });

    testWidgets("AnimatedSwitcher présent pour l'icône du bouton central", (tester) async {
      await tester.pumpWidget(wrap(buildNav()));
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });
  });

  group('UrbinkBottomNav — Dynamic Type (AC3)', () {
    testWidgets('les labels onglets ont maxLines:1 et overflow ellipsis', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(),
          mediaQuery: const MediaQueryData(
            textScaler: TextScaler.linear(3.0), // xxxLarge
          ),
        ),
      );
      // L'app ne doit pas provoquer d'overflow (pas d'exception RenderFlex)
      expect(tester.takeException(), isNull);

      final textWidgets = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(UrbinkBottomNav),
          matching: find.byType(Text),
        ),
      );
      const labels = ['Accueil', 'Carte', 'Challenges', 'Vous'];
      final labelTexts =
          textWidgets.where((text) => labels.contains(text.data)).toList();

      expect(labelTexts, hasLength(labels.length));
      for (final text in labelTexts) {
        expect(
          text.maxLines,
          1,
          reason: '${text.data} doit être limité à une seule ligne',
        );
        expect(
          text.overflow,
          TextOverflow.ellipsis,
          reason: '${text.data} doit utiliser ellipsis en cas de débordement',
        );
      }
    });

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

    testWidgets('labels onglets utilisent la police Inter du thème (labelSmall)',
        (tester) async {
      await tester.pumpWidget(wrap(buildNav()));

      final textWidgets = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(UrbinkBottomNav),
          matching: find.byType(Text),
        ),
      );

      // Les labels doivent utiliser le fontFamily Inter (bodyFamily du design system)
      const expectedFamily = 'Inter';
      final labels = ['Accueil', 'Carte', 'Challenges', 'Vous'];
      for (final text in textWidgets) {
        if (labels.contains(text.data)) {
          expect(
            text.style?.fontFamily,
            expectedFamily,
            reason: '${text.data} doit utiliser la police Inter du thème',
          );
        }
      }
    });
  });

  group('UrbinkBottomNav — Touch targets ≥ 44pt (AC4)', () {
    testWidgets('le bouton Démarrer fait 56×56', (tester) async {
      await tester.pumpWidget(wrap(buildNav()));

      final startButtonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        description: 'AnimatedContainer circulaire 56×56 du bouton Démarrer',
      );
      expect(startButtonFinder, findsOneWidget);

      // Vérification des dimensions réelles rendues par le moteur Flutter
      final size = tester.getSize(startButtonFinder);
      expect(size.width, 56.0);
      expect(size.height, 56.0);
    });

    testWidgets('tap sur onglet Carte déclenche onTabSelected(1)', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(buildNav(onTabSelected: (i) => tapped = i)),
      );

      await tester.tap(find.bySemanticsLabel(RegExp(r'Carte, onglet 2 sur 5')));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('tap sur bouton Démarrer déclenche onTabSelected(2)', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(buildNav(onTabSelected: (i) => tapped = i)),
      );

      await tester.tap(find.bySemanticsLabel('Démarrer, onglet 3 sur 5'));
      await tester.pump();
      expect(tapped, 2);
    });
  });

  group('UrbinkBottomNav — Safe areas iOS (AC5)', () {
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

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(UrbinkBottomNav),
          matching: find.byType(SizedBox).first,
        ),
      );

      // La hauteur doit inclure au minimum la hauteur de base + le padding safe area.
      expect(
        sizedBox.height,
        greaterThanOrEqualTo(UrbinkSpacing.bottomNavHeight + bottomPadding),
      );
    });

    testWidgets('rendu correct sans padding (iPhone SE)', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildNav(),
          mediaQuery: const MediaQueryData(
            padding: EdgeInsets.zero,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('UrbinkBottomNav — Couleurs session', () {
    testWidgets('bouton idle affiche icône play_arrow (Vert Sauge)', (tester) async {
      await tester.pumpWidget(wrap(buildNav(sessionState: SessionState.idle)));
      // Le Semantics du bouton idle contient "Démarrer"
      expect(find.bySemanticsLabel('Démarrer, onglet 3 sur 5'), findsOneWidget);
      // Et l'icône play_arrow est présente
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('bouton active affiche icône pause (Ocre)', (tester) async {
      await tester.pumpWidget(
        wrap(buildNav(sessionState: SessionState.active)),
      );
      // Le Semantics du bouton active contient "Pause session"
      expect(find.bySemanticsLabel('Pause session, onglet 3 sur 5'), findsOneWidget);
      // Et l'icône pause est présente
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });
}
