import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/gamification/models/monument_badge.dart';
import 'package:urbink/features/gamification/widgets/badge_grid.dart';
import 'package:urbink/features/map/models/monument.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _eiffel = Monument(
  id: 'tour-eiffel',
  name: 'Tour Eiffel',
  category: 'Palais & Monuments emblématiques',
  categoryIcon: '🗼',
  subtype: '',
  position: LatLng(48.8584, 2.2945),
);

const _louvre = Monument(
  id: 'louvre',
  name: 'Musée du Louvre',
  category: 'Musées & Bibliothèques',
  categoryIcon: '🏛️',
  subtype: '',
  position: LatLng(48.8606, 2.3376),
);

final _eiffelBadge = MonumentBadge(
  id: MonumentBadge.idFor('tour-eiffel'),
  monumentId: 'tour-eiffel',
  name: 'Tour Eiffel',
  emoji: '🗼',
  unlockedAt: DateTime(2026, 4, 27),
);

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BadgeGrid', () {
    testWidgets('affiche le nom de chaque monument', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const BadgeGrid(
            monuments: [_eiffel, _louvre],
            badges: [],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tour Eiffel'), findsOneWidget);
      expect(find.text('Musée du Louvre'), findsOneWidget);
    });

    testWidgets('badge verrouillé : affiche icône catégorie et verrou',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const BadgeGrid(
            monuments: [_louvre],
            badges: [],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('🔒'), findsOneWidget);
    });

    testWidgets('badge débloqué : affiche emoji et date, pas de verrou',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          BadgeGrid(
            monuments: const [_eiffel],
            badges: [_eiffelBadge],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('🗼'), findsOneWidget);
      expect(find.text('27/04/2026'), findsOneWidget);
      expect(find.text('🔒'), findsNothing);
    });

    testWidgets('grille vide si monuments est vide', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const BadgeGrid(
            monuments: [],
            badges: [],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('🔒'), findsNothing);
    });
  });
}
