import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/providers/map_layers_provider.dart';

ProviderContainer _makeContainer() => ProviderContainer();

void main() {
  group('mapLayersProvider', () {
    test('état initial : monuments ON, quartiers OFF, photos OFF', () {
      final c = _makeContainer();
      addTearDown(c.dispose);

      final layers = c.read(mapLayersProvider);
      expect(layers['monuments'], isTrue);
      expect(layers['quartiers'], isFalse);
      expect(layers['photos'], isFalse);
    });

    test('toggle monuments OFF → state mis à jour', () {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(mapLayersProvider.notifier).state = {
        'monuments': false,
        'photos': false,
      };

      expect(c.read(mapLayersProvider)['monuments'], isFalse);
    });

    test('toggle photos ON → state mis à jour', () {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(mapLayersProvider.notifier).state = {
        'monuments': true,
        'photos': true,
      };

      expect(c.read(mapLayersProvider)['photos'], isTrue);
      expect(c.read(mapLayersProvider)['monuments'], isTrue);
    });

    test('les clés monuments et photos sont toujours présentes', () {
      final c = _makeContainer();
      addTearDown(c.dispose);

      final layers = c.read(mapLayersProvider);
      expect(layers.containsKey('monuments'), isTrue);
      expect(layers.containsKey('photos'), isTrue);
    });
  });
}
