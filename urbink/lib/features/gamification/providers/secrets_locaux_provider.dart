import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/providers/city_provider.dart';

/// Charge le mapping arrondissement → secret local depuis l'asset local.
///
/// Injectable en tests via `overrideWith`.
final secretsLocauxProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final raw = await rootBundle
      .loadString('assets/geo/$city/secrets_locaux.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return map.cast<String, String>();
});
