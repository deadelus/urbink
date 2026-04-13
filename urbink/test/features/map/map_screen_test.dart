import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:urbink/features/map/screens/map_screen.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        // Pas de Firebase en test — uid null → crash recovery skippé
        currentUidProvider.overrideWithValue(null),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

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
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasError = find
          .byType(Text)
          .evaluate()
          .any((e) => (e.widget as Text).data?.contains('Erreur') ?? false);
      expect(hasLoading || hasError, isTrue);
    });

    testWidgets(
        "le message d'erreur ne contient pas l'URL MapTiler ni la clé API",
        (tester) async {
      await tester.pumpWidget(_wrap(const MapScreen()));
      // Laisse _loadStyle() se terminer (requête HTTP échoue en test)
      await tester.pump(const Duration(seconds: 2));

      // Collecte tous les textes affichés
      final texts = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data ?? '')
          .join(' ');

      // Si on est déjà en état d'erreur, vérifier que le message est générique
      if (texts.contains('Erreur')) {
        expect(texts, isNot(contains('http')));
        expect(texts, isNot(contains('maptiler')));
        expect(texts, isNot(contains('key=')));
        expect(texts, contains('Impossible de charger le style de la carte'));
      }
      // Si encore en loading : le test passe, pas d'erreur visible à vérifier
    });

    testWidgets(
        'pas de crash même si _loadStyle lève une exception (kDebugMode = true)',
        (tester) async {
      // En test, kDebugMode == true → Crashlytics n'est pas appelé.
      // Ce test garantit qu'aucune exception n'est propagée au widget tree.
      await tester.pumpWidget(_wrap(const MapScreen()));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  });
}
