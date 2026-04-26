import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/providers/city_provider.dart';
import 'package:urbink/features/map/models/monument.dart';

final monumentsProvider = FutureProvider<List<Monument>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final raw = await rootBundle.loadString('assets/geo/$city/monuments.json');
  final geojson = jsonDecode(raw) as Map<String, dynamic>;
  final features = geojson['features'] as List<dynamic>;
  return features
      .map((f) => Monument.fromGeoJsonFeature(f as Map<String, dynamic>))
      .toList();
});
