import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/badges/data/collection_model.dart';
import 'package:urbink/features/badges/widgets/objectif_card.dart';
import 'package:urbink/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MonumentCollection _makeCollection({
  String id = 'test',
  List<bool> lockedStates = const [true, true, true],
  List<String> transportModes = const ['foot'],
}) {
  return MonumentCollection(
    id: id,
    name: 'Test Collection',
    subtitle: 'Sous-titre test',
    icon: '⭐',
    color: Colors.amber,
    transportModes: transportModes,
    monuments: [
      for (int i = 0; i < lockedStates.length; i++)
        CollectionMonument(
          id: 'mon-$i',
          emoji: '🏛️',
          name: 'Monument $i',
          locked: lockedStates[i],
        ),
    ],
  );
}

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Scaffold(body: child),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ObjectifCard — affichage', () {
    testWidgets('affiche le nom de la collection', (tester) async {
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(),
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.text('Test Collection'), findsOneWidget);
    });

    testWidgets('affiche le sous-titre', (tester) async {
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(),
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.text('Sous-titre test'), findsOneWidget);
    });

    testWidgets('affiche la progression N/total', (tester) async {
      final col = _makeCollection(lockedStates: [false, true, true]);
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: col,
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.text('1 / 3 monuments'), findsOneWidget);
    });

    testWidgets('pill À pied visible quand mode foot', (tester) async {
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(transportModes: ['foot']),
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.textContaining('À pied'), findsOneWidget);
    });

    testWidgets('pill Vélo visible quand mode bike', (tester) async {
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(transportModes: ['foot', 'bike']),
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.textContaining('Vélo'), findsOneWidget);
    });

    testWidgets('bouton Activer visible quand inactif', (tester) async {
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(),
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.text('Activer'), findsOneWidget);
    });

    testWidgets('bouton Actif visible quand actif', (tester) async {
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(),
          isActive: true,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.text('Actif'), findsOneWidget);
    });

    testWidgets('label Complété visible quand 100%', (tester) async {
      final col = _makeCollection(lockedStates: [false, false, false]);
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: col,
          isActive: false,
          onTap: () {},
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      expect(find.textContaining('Complété'), findsOneWidget);
    });
  });

  group('ObjectifCard — interactions', () {
    testWidgets('onToggleActivation déclenché au tap bouton Activer',
        (tester) async {
      bool toggled = false;
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(),
          isActive: false,
          onTap: () {},
          onToggleActivation: () => toggled = true,
        )),
      );
      await tester.pump();
      await tester.tap(find.text('Activer'));
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('onTap déclenché au tap sur la carte', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(ObjectifCard(
          collection: _makeCollection(),
          isActive: false,
          onTap: () => tapped = true,
          onToggleActivation: () {},
        )),
      );
      await tester.pump();
      await tester.tap(find.text('Test Collection'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
