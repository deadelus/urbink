import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/gamification/widgets/quartier_celebration_overlay.dart';
import 'package:urbink/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: Scaffold(body: child),
    );

// Remplace le widget par un SizedBox vide pour déclencher dispose() et
// annuler les timers avant la vérification post-test du framework.
Future<void> _disposeWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
}

void main() {
  group('QuartierCelebrationOverlay', () {
    testWidgets('affiche le titre avec le nom du quartier', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '1er',
            secretLocal: 'Secret du 1er.',
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('1er'), findsAtLeastNWidgets(1));
      await _disposeWidget(tester);
    });

    testWidgets('affiche le secret local', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '1er',
            secretLocal: 'La Pyramide du Louvre compte 673 vitres.',
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('La Pyramide du Louvre compte 673 vitres.'),
        findsOneWidget,
      );
      await _disposeWidget(tester);
    });

    testWidgets('affiche le label Secret local', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '1er',
            secretLocal: 'Secret',
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Secret local'), findsOneWidget);
      await _disposeWidget(tester);
    });

    testWidgets('appelle onContinue quand le bouton Continuer est tapé',
        (tester) async {
      var called = false;

      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '18e',
            secretLocal: 'Secret du 18e.',
            onContinue: () => called = true,
          ),
        ),
      );
      await tester.pump();

      final buttons = find.byType(FilledButton);
      await tester.tap(buttons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(called, isTrue);
    });

    testWidgets('affiche le bouton Partager si onShare est fourni',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '9e',
            secretLocal: 'Secret',
            onShare: () {},
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(OutlinedButton), findsOneWidget);
      await _disposeWidget(tester);
    });

    testWidgets('masque le bouton Partager si onShare est null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '9e',
            secretLocal: 'Secret',
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(OutlinedButton), findsNothing);
      await _disposeWidget(tester);
    });

    testWidgets('affiche le trophée 🏆', (tester) async {
      await tester.pumpWidget(
        _wrap(
          QuartierCelebrationOverlay(
            quartierName: '3e',
            secretLocal: 'Secret',
            onContinue: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('🏆'), findsAtLeastNWidgets(1));
      await _disposeWidget(tester);
    });
  });
}
