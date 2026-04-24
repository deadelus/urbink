import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/providers/time_filter_provider.dart';

// Heure fixe (milieu de journée) pour éviter toute flakiness autour de minuit.
final _fixedNow = DateTime(2024, 6, 15, 10, 30);

void main() {
  group('TimeFilterX.from', () {
    test('allTime retourne null', () {
      expect(TimeFilter.allTime.from(_fixedNow), isNull);
    });

    test('today retourne minuit du jour courant', () {
      expect(TimeFilter.today.from(_fixedNow), DateTime(2024, 6, 15));
    });

    test('thisWeek retourne minuit il y a 7 jours', () {
      expect(TimeFilter.thisWeek.from(_fixedNow), DateTime(2024, 6, 8));
    });

    test('thisMonth retourne le 1er du mois courant', () {
      expect(TimeFilter.thisMonth.from(_fixedNow), DateTime(2024, 6, 1));
    });
  });

  group('TimeFilterX.label', () {
    test('chaque filtre a un label non vide', () {
      for (final f in TimeFilter.values) {
        expect(f.label, isNotEmpty);
      }
    });

    test("today label contient Aujourd'hui", () {
      expect(TimeFilter.today.label, contains("Aujourd'hui"));
    });
  });
}
