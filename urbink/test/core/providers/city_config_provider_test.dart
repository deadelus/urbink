import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/core/config/city_config.dart';
import 'package:urbink/core/providers/city_config_provider.dart';
import 'package:urbink/core/providers/city_provider.dart';

void main() {
  group('cityConfigProvider', () {
    test('retourne la config paris par défaut', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final config = c.read(cityConfigProvider);
      expect(config.id, 'paris');
    });

    test('suit currentCityProvider', () {
      // Simuler un slug inconnu → fallback paris
      final c = ProviderContainer(
        overrides: [
          currentCityProvider.overrideWith((ref) => 'unknown_city'),
        ],
      );
      addTearDown(c.dispose);

      final config = c.read(cityConfigProvider);
      expect(config.id, 'paris'); // fallback
    });

    test('change de config quand currentCityProvider change', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      citiesRegistry['test_city'] = CityConfig(
        id: 'test_city',
        center: citiesRegistry['paris']!.center,
        initialZoom: 12.0,
        zoneLevels: const [],
      );
      addTearDown(() => citiesRegistry.remove('test_city'));

      c.read(currentCityProvider.notifier).state = 'test_city';
      expect(c.read(cityConfigProvider).id, 'test_city');
    });
  });
}
