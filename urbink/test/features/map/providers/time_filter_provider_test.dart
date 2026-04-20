import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/providers/time_filter_provider.dart';

void main() {
  group('TimeFilterX.from', () {
    test('allTime retourne null', () {
      expect(TimeFilter.allTime.from, isNull);
    });

    test('today retourne minuit du jour courant', () {
      final now = DateTime.now();
      final from = TimeFilter.today.from!;
      expect(from.year, now.year);
      expect(from.month, now.month);
      expect(from.day, now.day);
      expect(from.hour, 0);
      expect(from.minute, 0);
      expect(from.second, 0);
    });

    test('thisWeek retourne minuit il y a 7 jours', () {
      final now = DateTime.now();
      final from = TimeFilter.thisWeek.from!;
      expect(from, DateTime(now.year, now.month, now.day - 7));
    });

    test('thisMonth retourne le 1er du mois courant', () {
      final now = DateTime.now();
      final from = TimeFilter.thisMonth.from!;
      expect(from.year, now.year);
      expect(from.month, now.month);
      expect(from.day, 1);
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
