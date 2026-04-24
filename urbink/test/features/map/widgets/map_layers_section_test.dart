import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/widgets/map_layers_section.dart';
import 'package:urbink/l10n/app_localizations.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

const _defaultValues = {
  'monuments': true,
  'quartiers': false,
  'photos': false,
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MapLayersSection', () {
    // AC-a — rendu des 3 couches
    testWidgets('AC-a — affiche les 3 rows', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MapLayersSection(values: _defaultValues, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Monuments visités'), findsOneWidget);
      expect(find.text('Délimitations quartiers'), findsOneWidget);
      expect(find.text('Photos épinglées'), findsOneWidget);
    });

    // AC-a — titre de section visible
    testWidgets('AC-a — titre "Affichage carte" visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MapLayersSection(values: _defaultValues, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Affichage carte'), findsOneWidget);
    });

    // AC-b — tap row appelle onChanged avec la bonne clé flippée
    testWidgets('AC-b — tap monuments : true → false', (tester) async {
      Map<String, bool>? captured;

      await tester.pumpWidget(
        _wrap(
          MapLayersSection(
            values: _defaultValues,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monuments visités'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!['monuments'], isFalse);
      expect(captured!['quartiers'], isFalse); // inchangé
      expect(captured!['photos'], isFalse);    // inchangé
    });

    testWidgets('AC-b — tap quartiers : false → true', (tester) async {
      Map<String, bool>? captured;

      await tester.pumpWidget(
        _wrap(
          MapLayersSection(
            values: _defaultValues,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Délimitations quartiers'));
      await tester.pump();

      expect(captured!['quartiers'], isTrue);
      expect(captured!['monuments'], isTrue); // inchangé
      expect(captured!['photos'], isFalse);   // inchangé
    });

    testWidgets('AC-b — tap photos : false → true', (tester) async {
      Map<String, bool>? captured;

      await tester.pumpWidget(
        _wrap(
          MapLayersSection(
            values: _defaultValues,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Photos épinglées'));
      await tester.pump();

      expect(captured!['photos'], isTrue);
      expect(captured!['monuments'], isTrue);  // inchangé
      expect(captured!['quartiers'], isFalse); // inchangé
    });

    // AC-c — Switch reflète values[key]
    testWidgets('AC-c — Switch ON/OFF reflète les valeurs initiales',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          MapLayersSection(
            values: const {'monuments': true, 'quartiers': false, 'photos': false},
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isTrue);   // monuments ON
      expect(switches[1].value, isFalse);  // quartiers OFF
      expect(switches[2].value, isFalse);  // photos OFF
    });

    testWidgets('AC-c — Switch se met à jour quand le parent change values',
        (tester) async {
      var values = const <String, bool>{
        'monuments': true,
        'quartiers': false,
        'photos': false,
      };

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => MapLayersSection(
              values: values,
              onChanged: (v) => setState(() => values = v),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Avant tap : monuments ON
      expect(
        tester.widgetList<Switch>(find.byType(Switch)).first.value,
        isTrue,
      );

      await tester.tap(find.text('Monuments visités'));
      await tester.pumpAndSettle();

      // Après tap : monuments OFF
      expect(
        tester.widgetList<Switch>(find.byType(Switch)).first.value,
        isFalse,
      );
    });
  });
}
