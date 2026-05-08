import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/screens/monument_detail_sheet.dart';
import 'package:urbink/features/badges/widgets/mini_map.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _col = MonumentCollection(
  id: 'indispensables',
  name: 'Les Indispensables',
  subtitle: 'Le must absolu',
  icon: '⭐',
  color: Color(0xFFF59E0B),
  monuments: [],
);

const _locked = CollectionMonument(
  id: 'PA00088801',
  emoji: '🗼',
  name: 'Tour Eiffel',
  location: LatLng(48.8584, 2.2945),
  locked: true,
  arrondissement: '7e',
  era: '1889',
  description: 'Le symbole de Paris.',
);

const _unlocked = CollectionMonument(
  id: 'PA00086250',
  emoji: '🏰',
  name: 'Notre-Dame',
  location: LatLng(48.8530, 2.3499),
  locked: false,
  arrondissement: '4e',
  era: 'XIIᵉ',
  description: 'Cathédrale gothique sur l\'Île de la Cité.',
);

// ---------------------------------------------------------------------------
// Helper — app minimaliste avec ProviderScope (pas de GoRouter)
// ---------------------------------------------------------------------------

Widget _wrap({required CollectionMonument monument}) {
  return ProviderScope(
    child: MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => MonumentDetailSheet.show(
            context,
            monument: monument,
            collection: _col,
            onShowOnMap: () {},
          ),
          child: const Text('Ouvrir'),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests modèle
// ---------------------------------------------------------------------------

void main() {
  group('CollectionMonument — nouveaux champs', () {
    test('champs optionnels ont des valeurs par défaut vides', () {
      const m = CollectionMonument(
        id: 'test',
        emoji: '🏛️',
        name: 'Test',
      );
      expect(m.arrondissement, '');
      expect(m.era, '');
      expect(m.description, '');
    });

    test('withLocked préserve arrondissement, era, description', () {
      const m = CollectionMonument(
        id: 'test',
        emoji: '🏛️',
        name: 'Test',
        arrondissement: '4e',
        era: '1889',
        description: 'Description.',
      );
      final copy = m.withLocked(false);
      expect(copy.arrondissement, '4e');
      expect(copy.era, '1889');
      expect(copy.description, 'Description.');
      expect(copy.locked, false);
    });

    test('champs renseignés sont bien retournés', () {
      expect(_locked.arrondissement, '7e');
      expect(_locked.era, '1889');
      expect(_locked.description, 'Le symbole de Paris.');
    });
  });

  // -------------------------------------------------------------------------
  // Tests widget — MiniMap
  // -------------------------------------------------------------------------

  group('MiniMap', () {
    testWidgets('se rend sans erreur (monument avec location)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniMap(
              monument: LatLng(48.8584, 2.2945),
              accentColor: Color(0xFFF59E0B),
              arrondissement: '7e',
              unlocked: false,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('affiche la pill arrondissement', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniMap(
              monument: LatLng(48.8584, 2.2945),
              accentColor: Color(0xFFF59E0B),
              arrondissement: '7e',
              unlocked: false,
            ),
          ),
        ),
      );
      expect(find.text('7e'), findsOneWidget);
    });

    testWidgets('affiche la pill Visité ✓ si débloqué', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniMap(
              monument: LatLng(48.8530, 2.3499),
              accentColor: Color(0xFFF59E0B),
              arrondissement: '4e',
              unlocked: true,
            ),
          ),
        ),
      );
      expect(find.text('Visité ✓'), findsOneWidget);
    });

    testWidgets('se rend sans erreur si location est null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniMap(
              monument: null,
              accentColor: Color(0xFF256F4C),
              arrondissement: '',
              unlocked: false,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Tests widget — MonumentDetailSheet
  // -------------------------------------------------------------------------

  group('MonumentDetailSheet', () {
    testWidgets('affiche le nom du monument après ouverture', (tester) async {
      await tester.pumpWidget(_wrap(monument: _locked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Tour Eiffel'), findsOneWidget);
    });

    testWidgets('monument verrouillé affiche "Pas encore visité"',
        (tester) async {
      await tester.pumpWidget(_wrap(monument: _locked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Pas encore visité'), findsOneWidget);
    });

    testWidgets('monument débloqué affiche "Badge débloqué"', (tester) async {
      await tester.pumpWidget(_wrap(monument: _unlocked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Badge débloqué'), findsOneWidget);
    });

    testWidgets('affiche la description du monument', (tester) async {
      await tester.pumpWidget(_wrap(monument: _locked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Le symbole de Paris.'), findsOneWidget);
    });

    testWidgets('bouton × ferme la sheet', (tester) async {
      await tester.pumpWidget(_wrap(monument: _locked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Tour Eiffel'), findsOneWidget);

      await tester.tap(find.text('×'));
      await tester.pumpAndSettle();

      expect(find.text('Tour Eiffel'), findsNothing);
    });

    testWidgets('bouton Partager est présent', (tester) async {
      await tester.pumpWidget(_wrap(monument: _locked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Partager'), findsOneWidget);
    });

    testWidgets('bouton Voir sur la carte est présent', (tester) async {
      await tester.pumpWidget(_wrap(monument: _locked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Voir sur la carte'), findsOneWidget);
    });

    testWidgets('tap backdrop ferme la sheet', (tester) async {
      await tester.pumpWidget(_wrap(monument: _unlocked));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Notre-Dame'), findsOneWidget);

      // Tap hors de la sheet (en haut de l'écran)
      await tester.tapAt(const Offset(200, 10));
      await tester.pumpAndSettle();

      expect(find.text('Notre-Dame'), findsNothing);
    });
  });
}
