import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/core/config/city_config.dart';

void main() {
  group('citiesRegistry', () {
    test('paris est présent dans le registre', () {
      expect(citiesRegistry.containsKey('paris'), isTrue);
    });

    test('paris a un centre autour de 48.85°N 2.35°E', () {
      final paris = citiesRegistry['paris']!;
      expect(paris.center.latitude, closeTo(48.85, 0.1));
      expect(paris.center.longitude, closeTo(2.35, 0.1));
    });

    test('paris a deux niveaux de zones', () {
      expect(citiesRegistry['paris']!.zoneLevels.length, 2);
    });

    test('premier niveau paris = arrondissements', () {
      expect(citiesRegistry['paris']!.zoneLevels.first.assetKey, 'arrondissements');
    });

    test('deuxième niveau paris = quartiers', () {
      expect(citiesRegistry['paris']!.zoneLevels.last.assetKey, 'quartiers');
    });
  });

  group('CityConfig.activeLevelFor', () {
    final paris = citiesRegistry['paris']!;

    test('zoom 10 → arrondissements', () {
      expect(paris.activeLevelFor(10.0)?.assetKey, 'arrondissements');
    });

    test('zoom 13.4 → arrondissements', () {
      expect(paris.activeLevelFor(13.4)?.assetKey, 'arrondissements');
    });

    test('zoom 13.5 → quartiers', () {
      expect(paris.activeLevelFor(13.5)?.assetKey, 'quartiers');
    });

    test('zoom 17.0 → quartiers', () {
      expect(paris.activeLevelFor(17.0)?.assetKey, 'quartiers');
    });
  });

  group('ZoneLevelConfig.labelBuilder (Paris)', () {
    final arrLevel = citiesRegistry['paris']!.zoneLevels.first;
    final qrtLevel = citiesRegistry['paris']!.zoneLevels.last;

    // Noms réels dans assets/geo/paris/arrondissements.json : "1er", "2e", "14e"
    test('arrondissements : "1er" → "1"', () {
      expect(arrLevel.labelBuilder!('1er'), '1');
    });

    test('arrondissements : "2e" → "2"', () {
      expect(arrLevel.labelBuilder!('2e'), '2');
    });

    test('arrondissements : "14e" → "14"', () {
      expect(arrLevel.labelBuilder!('14e'), '14');
    });

    // Noms réels dans assets/geo/paris/quartiers.json : "Bel-Air", "Bercy"…
    test('quartiers : label → MAJUSCULES', () {
      expect(qrtLevel.labelBuilder!('Bel-Air'), 'BEL-AIR');
    });
  });
}
