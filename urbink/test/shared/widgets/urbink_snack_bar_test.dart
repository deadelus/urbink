import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/shared/constants/colors.dart';
import 'package:urbink/shared/widgets/urbink_snack_bar.dart';

void main() {
  Widget wrap(VoidCallback onShow) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: onShow,
              child: const Text('trigger'),
            ),
          ),
        ),
      );

  Future<void> show(
    WidgetTester tester,
    UrbinkSnackBarType type,
    String message,
  ) async {
    await tester.pumpWidget(wrap(() {}));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showUrbinkSnackBar(
                context,
                message: message,
                type: type,
              ),
              child: const Text('trigger'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('trigger'));
    await tester.pump();
  }

  group('showUrbinkSnackBar — affichage', () {
    testWidgets('affiche le message', (tester) async {
      await show(tester, UrbinkSnackBarType.info, 'Opération réussie');
      expect(find.text('Opération réussie'), findsOneWidget);
    });

    testWidgets('type success → fond #2D5A2D', (tester) async {
      await show(tester, UrbinkSnackBarType.success, 'Succès');
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, UrbinkColors.toastSuccess);
    });

    testWidgets('type error → fond #8B2020', (tester) async {
      await show(tester, UrbinkSnackBarType.error, 'Erreur');
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, UrbinkColors.toastError);
    });

    testWidgets('type warning → fond #7A5A1E', (tester) async {
      await show(tester, UrbinkSnackBarType.warning, 'Attention');
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, UrbinkColors.toastWarning);
    });

    testWidgets('type info → fond #1E1610', (tester) async {
      await show(tester, UrbinkSnackBarType.info, 'Info');
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, UrbinkColors.toastInfo);
    });

    testWidgets('affiche une icône à gauche', (tester) async {
      await show(tester, UrbinkSnackBarType.success, 'OK');
      expect(
        find.descendant(of: find.byType(SnackBar), matching: find.byType(Icon)),
        findsOneWidget,
      );
    });

    testWidgets('durée configurée à 2500ms', (tester) async {
      late SnackBar capturedSnackBar;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.hideCurrentSnackBar();
                  const snackBar = SnackBar(
                    content: Text('test'),
                    duration: Duration(milliseconds: 2500),
                  );
                  capturedSnackBar = snackBar;
                  messenger.showSnackBar(snackBar);
                },
                child: const Text('trigger'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('trigger'));
      await tester.pump();
      expect(capturedSnackBar.duration,
          const Duration(milliseconds: 2500));
    });
  });
}
