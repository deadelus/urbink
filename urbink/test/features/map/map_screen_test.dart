import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urbink/features/map/screens/map_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('MapScreen', () {
    testWidgets('se construit sans erreur (smoke test)', (tester) async {
      await tester.pumpWidget(_wrap(const MapScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('affiche un état (loading ou erreur) sans crash réseau',
        (tester) async {
      await tester.pumpWidget(_wrap(const MapScreen()));
      await tester.pump();
      // En test, MAPTILER_KEY est vide → loading ou erreur, jamais de crash
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasError = find.byType(Text).evaluate()
          .any((e) => (e.widget as Text).data?.contains('Erreur') ?? false);
      expect(hasLoading || hasError, isTrue);
    });
  });
}
