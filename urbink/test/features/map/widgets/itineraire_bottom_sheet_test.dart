import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/widgets/itineraire_bottom_sheet.dart';
import 'package:urbink/shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );

/// Drag the sheet from PARTIAL (80px) up to OPEN.
///
/// Also bumps the viewport to 900px tall so the 65%-height sheet leaves
/// > 300px for the LayoutBuilder guards inside _ManualContent / _AutoGenerateContent.
Future<void> _openSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  await tester.pump();

  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final startPoint = Offset(size.width / 2, size.height - 40);
  await tester.dragFrom(startPoint, const Offset(0, -500));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ItineraireBottomSheet', () {
    // AC1 — collapsed hint visible, body not shown
    testWidgets('AC1 — starts PARTIAL with step counter, no toggle visible',
        (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      // Step counter hint is visible (mock has 5 POIs)
      expect(find.text('5 étapes'), findsOneWidget);

      // Manuel/Auto toggle is hidden until expanded
      expect(find.text('Manuel'), findsNothing);
      expect(find.text('Auto ✨'), findsNothing);
    });

    // AC2 — drag up shows body with Manuel/Auto toggle
    testWidgets('AC2 — drag up shows Manuel/Auto toggle and POI list',
        (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('Manuel'), findsOneWidget);
      expect(find.text('Auto ✨'), findsOneWidget);
      expect(find.text('Étapes du parcours'), findsOneWidget);
    });

    // AC3 — Manuel tab shows POI list with mock data
    testWidgets('AC3 — Manuel tab shows mock POIs', (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      // Mock POI from _mockPois
      expect(find.text('Tour Eiffel'), findsOneWidget);
    });

    // AC4 — switch to Auto tab shows duration selector
    testWidgets('AC4 — tap Auto ✨ shows duration selector and Générer CTA',
        (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      await tester.tap(find.text('Auto ✨'));
      await tester.pumpAndSettle();

      expect(find.text("Générer l'itinéraire"), findsOneWidget);
    });

    // AC5 — switch back to Manuel from Auto
    testWidgets('AC5 — tap Manuel from Auto returns to POI list', (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      await tester.tap(find.text('Auto ✨'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manuel'));
      await tester.pumpAndSettle();

      expect(find.text('Étapes du parcours'), findsOneWidget);
    });

    // AC6 — CTA "Créer l'itinéraire" visible only with ≥ 3 POIs
    testWidgets('AC6 — CTA Créer visible when ≥ 3 POIs', (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      // Mock starts with 5 POIs → CTA should be visible
      expect(find.text("Créer l'itinéraire"), findsOneWidget);
    });

    // AC7 — remove POI reduces step count
    testWidgets('AC7 — tap remove on a POI reduces step counter', (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      // There are 5 POIs; find the first remove icon button and tap it
      final removeButtons = find.byIcon(Icons.remove_circle_outline_rounded);
      expect(removeButtons, findsWidgets);

      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      // Expanded badge shows "count / min. 3"
      expect(find.text('4 / min. 3'), findsOneWidget);
    });

    // AC8 — Auto generate then apply switches back to Manuel tab
    testWidgets('AC8 — Générer then Utiliser switches back to Manuel',
        (tester) async {
      await tester.pumpWidget(_wrap(const ItineraireBottomSheet()));
      await tester.pumpAndSettle();

      await _openSheet(tester);

      await tester.tap(find.text('Auto ✨'));
      await tester.pumpAndSettle();

      // Tap "Générer l'itinéraire" — uses default duration (15 min)
      await tester.tap(find.text("Générer l'itinéraire"));
      await tester.pumpAndSettle();

      // Result view shows "Utiliser cet itinéraire"
      expect(find.text('Utiliser cet itinéraire'), findsOneWidget);

      await tester.tap(find.text('Utiliser cet itinéraire'));
      await tester.pumpAndSettle();

      // Should be back on Manuel tab with generated POIs
      expect(find.text('Manuel'), findsOneWidget);
      expect(find.text('Étapes du parcours'), findsOneWidget);
    });
  });
}
