import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/profile/providers/week_histogram_provider.dart';

void main() {
  group('startOfWeek', () {
    test('lundi reste lundi', () {
      final monday = DateTime(2026, 4, 20); // lundi
      expect(startOfWeek(monday), DateTime(2026, 4, 20));
    });

    test('mercredi → lundi de la même semaine', () {
      final wednesday = DateTime(2026, 4, 22); // mercredi
      expect(startOfWeek(wednesday), DateTime(2026, 4, 20));
    });

    test('dimanche → lundi 6 jours avant', () {
      final sunday = DateTime(2026, 4, 26); // dimanche
      expect(startOfWeek(sunday), DateTime(2026, 4, 20));
    });

    test('vendredi → lundi de la même semaine', () {
      final friday = DateTime(2026, 4, 24); // vendredi
      expect(startOfWeek(friday), DateTime(2026, 4, 20));
    });

    test('retourne un DateTime à minuit (heure locale)', () {
      final date = DateTime(2026, 4, 23, 14, 30, 0);
      final result = startOfWeek(date);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });
}
