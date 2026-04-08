import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/widgets/urbink_button.dart';
import 'package:urbink/shared/widgets/urbink_empty_state.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('UrbinkEmptyState', () {
    testWidgets('affiche emoji et titre', (tester) async {
      await tester.pumpWidget(wrap(
        const UrbinkEmptyState(emoji: '🗺️', title: 'Aucun itinéraire'),
      ));
      expect(find.text('🗺️'), findsOneWidget);
      expect(find.text('Aucun itinéraire'), findsOneWidget);
    });

    testWidgets('affiche subtitle si fourni', (tester) async {
      await tester.pumpWidget(wrap(
        const UrbinkEmptyState(
          emoji: '🗺️',
          title: 'Aucun itinéraire',
          subtitle: 'Crée ton premier parcours.',
        ),
      ));
      expect(find.text('Crée ton premier parcours.'), findsOneWidget);
    });

    testWidgets('pas de subtitle si non fourni', (tester) async {
      await tester.pumpWidget(wrap(
        const UrbinkEmptyState(emoji: '🗺️', title: 'Aucun itinéraire'),
      ));
      expect(find.byType(UrbinkButton), findsNothing);
    });

    testWidgets('affiche CTA si ctaLabel + onCta fournis', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        UrbinkEmptyState(
          emoji: '🗺️',
          title: 'Aucun itinéraire',
          ctaLabel: 'Créer',
          onCta: () => tapped = true,
        ),
      ));
      expect(find.byType(UrbinkButton), findsOneWidget);
      expect(find.text('Créer'), findsOneWidget);
      await tester.tap(find.byType(UrbinkButton));
      expect(tapped, isTrue);
    });

    testWidgets('pas de CTA si ctaLabel et onCta tous les deux absents', (tester) async {
      await tester.pumpWidget(wrap(
        const UrbinkEmptyState(
          emoji: '🗺️',
          title: 'Aucun itinéraire',
          // ctaLabel et onCta tous les deux null → aucun bouton
        ),
      ));
      expect(find.byType(UrbinkButton), findsNothing);
    });

    testWidgets('emoji affiché en fontSize 56', (tester) async {
      await tester.pumpWidget(wrap(
        const UrbinkEmptyState(emoji: '🗺️', title: 'Test'),
      ));
      final emojiText = tester.widget<Text>(
        find.text('🗺️'),
      );
      expect(emojiText.style?.fontSize, 56);
    });
  });
}
