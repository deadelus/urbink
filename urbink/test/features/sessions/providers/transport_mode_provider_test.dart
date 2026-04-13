import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/transport_mode_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TransportModeNotifier', () {
    test('état initial = walking', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(transportModeProvider), TransportMode.walking);
    });

    test('select() change l\'état immédiatement', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(transportModeProvider.notifier).select(TransportMode.cycling);

      expect(container.read(transportModeProvider), TransportMode.cycling);
    });

    test('select() persiste dans SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(transportModeProvider.notifier).select(TransportMode.driving);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('urbink_transport_mode'), 'driving');
    });

    test('charge le mode sauvegardé au démarrage', () async {
      SharedPreferences.setMockInitialValues({
        'urbink_transport_mode': 'cycling',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Déclencher l'initialisation puis attendre que _loadFromPrefs se termine
      container.read(transportModeProvider);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(transportModeProvider), TransportMode.cycling);
    });
  });
}
