import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/constants/spacing.dart';
import 'package:urbink/shared/widgets/urbink_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('UrbinkButton — variante Primary', () {
    testWidgets('affiche le label', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(label: 'Démarrer', onPressed: () {}),
      ));
      expect(find.text('Démarrer'), findsOneWidget);
    });

    testWidgets('hauteur 52pt', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(label: 'Démarrer', onPressed: () {}),
      ));
      final box = tester.renderObject<RenderBox>(find.byType(UrbinkButton));
      expect(box.size.height, 52);
    });

    testWidgets('fond Ocre #B8832E', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(label: 'Démarrer', onPressed: () {}),
      ));
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = btn.style!.copyWith();
      final bg = style.backgroundColor?.resolve({});
      expect(bg, UrbinkColors.primary);
    });

    testWidgets('isLoading : spinner visible, bouton non interactif', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(label: 'Démarrer', onPressed: () {}, isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Démarrer'), findsNothing);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('déclenche onPressed au tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        UrbinkButton(label: 'Go', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(UrbinkButton));
      expect(tapped, isTrue);
    });

    testWidgets('affiche icône si fournie', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(
          label: 'Partager',
          onPressed: () {},
          icon: Icons.share,
        ),
      ));
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.text('Partager'), findsOneWidget);
    });
  });

  group('UrbinkButton — variante Secondary', () {
    testWidgets('rendu OutlinedButton', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(
          label: 'Modifier',
          onPressed: () {},
          variant: UrbinkButtonVariant.secondary,
        ),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('contour Ocre 1.5px', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(
          label: 'Modifier',
          onPressed: () {},
          variant: UrbinkButtonVariant.secondary,
        ),
      ));
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final side = btn.style!.side?.resolve({});
      expect(side?.color, UrbinkColors.primary);
      expect(side?.width, 1.5);
    });
  });

  group('UrbinkButton — variante Destructive', () {
    testWidgets('rendu TextButton', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(
          label: 'Supprimer',
          onPressed: () {},
          variant: UrbinkButtonVariant.destructive,
        ),
      ));
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('couleur texte Rouge #C0392B', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(
          label: 'Supprimer',
          onPressed: () {},
          variant: UrbinkButtonVariant.destructive,
        ),
      ));
      final btn = tester.widget<TextButton>(find.byType(TextButton));
      final fg = btn.style!.foregroundColor?.resolve({});
      expect(fg, UrbinkColors.destructive);
    });
  });

  group('UrbinkButton — zone tactile', () {
    testWidgets('largeur infinie (full width)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: UrbinkButton(label: 'Test', onPressed: () {}),
            ),
          ),
        ),
      );
      final box = tester.renderObject<RenderBox>(find.byType(UrbinkButton));
      expect(box.size.width, 300);
    });

    testWidgets('hauteur minimum respecte minTapTarget', (tester) async {
      await tester.pumpWidget(wrap(
        UrbinkButton(label: 'Test', onPressed: () {}),
      ));
      final box = tester.renderObject<RenderBox>(find.byType(UrbinkButton));
      expect(box.size.height, greaterThanOrEqualTo(UrbinkSpacing.minTapTarget));
    });
  });
}
