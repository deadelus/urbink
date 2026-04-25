import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/providers/city_provider.dart';
import 'package:urbink/features/map/models/zone_data.dart';

/// Charge un niveau de zones (`arrondissements`, `quartiers`, etc.) pour la
/// ville active depuis `assets/geo/{city}/{assetKey}.json`.
///
/// Utilisé par [MapZonesOverlay] via [ZoneLevelConfig.assetKey].
final zonesProviderFamily =
    FutureProvider.autoDispose.family<List<ZoneData>, String>((ref, assetKey) async {
  final city = ref.watch(currentCityProvider);
  final raw = await rootBundle.loadString('assets/geo/$city/$assetKey.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => ZoneData.fromJson(e as Map<String, dynamic>))
      .toList();
});
