import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:urbink/features/parcours/widgets/route_map_preview.dart';
import 'package:urbink/shared/constants/colors.dart';

const _points = [
  LatLng(48.8566, 2.3522),
  LatLng(48.8600, 2.3550),
  LatLng(48.8630, 2.3600),
];

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('RouteMapPreview — variante small', () {
    testWidgets('dimensions 176×85px', (tester) async {
      await tester.pumpWidget(
        _wrap(const RouteMapPreview(points: _points)),
      );
      final size = tester.getSize(find.byType(RouteMapPreview));
      expect(size.width, 176);
      expect(size.height, 85);
    });

    testWidgets('se rend sans erreur avec points vides', (tester) async {
      await tester.pumpWidget(
        _wrap(const RouteMapPreview(points: [])),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('se rend sans erreur avec un seul point', (tester) async {
      await tester.pumpWidget(
        _wrap(const RouteMapPreview(points: [LatLng(48.8566, 2.3522)])),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('RouteMapPreview — variante medium', () {
    testWidgets('ratio 16:9 respecté', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 320,
            child: RouteMapPreview(
              points: _points,
              variant: RouteMapVariant.medium,
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(RouteMapPreview));
      expect(size.width / size.height, closeTo(16 / 9, 0.01));
    });
  });

  group('RouteMapPreview — variante thumbnail', () {
    testWidgets('dimensions 48×48px', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RouteMapPreview(
            points: _points,
            variant: RouteMapVariant.thumbnail,
          ),
        ),
      );
      final size = tester.getSize(find.byType(RouteMapPreview));
      expect(size.width, 48);
      expect(size.height, 48);
    });
  });

  group('RouteMapPreview — isSession flag', () {
    testWidgets('session=false utilise la couleur Ocre pour la polyline', (tester) async {
      await tester.pumpWidget(
        _wrap(const RouteMapPreview(points: _points)),
      );
      expect(tester.takeException(), isNull);
      final painter = find.descendant(
        of: find.byType(RouteMapPreview),
        matching: find.byType(CustomPaint),
      );
      expect(painter, paints..rect()..path(color: UrbinkColors.ocre));
    });

    testWidgets('session=true utilise la couleur Vert Sauge pour la polyline', (tester) async {
      await tester.pumpWidget(
        _wrap(const RouteMapPreview(points: _points, isSession: true)),
      );
      expect(tester.takeException(), isNull);
      final painter = find.descendant(
        of: find.byType(RouteMapPreview),
        matching: find.byType(CustomPaint),
      );
      expect(painter, paints..rect()..path(color: UrbinkColors.streetExplored));
    });
  });
}
