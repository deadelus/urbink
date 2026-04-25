import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/config/city_config.dart';
import 'package:urbink/core/providers/city_provider.dart';

/// Configuration de la ville active — dérivée de [currentCityProvider].
///
/// Fallback sur Paris si le slug n'est pas dans le registre.
final cityConfigProvider = Provider<CityConfig>((ref) {
  final city = ref.watch(currentCityProvider);
  return citiesRegistry[city] ?? citiesRegistry['paris']!;
});
