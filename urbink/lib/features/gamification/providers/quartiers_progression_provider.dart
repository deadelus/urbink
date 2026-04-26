import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/providers/city_provider.dart';
import 'package:urbink/features/gamification/models/quartier_progression.dart';
import 'package:urbink/features/map/providers/aggregation_provider.dart';
import 'package:urbink/features/map/providers/zones_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Charge le mapping arrondissement → Set de streetIds OSM depuis l'asset local.
///
/// Injectable en tests via `overrideWith` — évite rootBundle dans les tests.
final arrondissementStreetsProvider =
    FutureProvider<Map<String, Set<String>>>((ref) async {
  final city = ref.watch(currentCityProvider);
  final raw = await rootBundle
      .loadString('assets/geo/$city/arrondissement_streets.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return map.map((k, v) => MapEntry(k, Set<String>.from(v as List)));
});

/// Progression de complétion (% rues explorées) pour chaque arrondissement,
/// triée par % décroissant (le plus avancé en premier).
///
/// Utilise toutes les sessions sans filtre temporel — la progression quartier
/// est always all-time, contrairement à [aggregationProvider].
final quartiersProgressionProvider =
    StreamProvider<List<QuartierProgression>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);

  final sessionsStream =
      ref.watch(sessionsStreetIdsStreamProvider((uid, null)));

  return sessionsStream.asyncMap((sessions) async {
    final streetsMap =
        await ref.read(arrondissementStreetsProvider.future);
    final zones =
        await ref.read(zonesProviderFamily('arrondissements').future);

    final nameMap = {for (final z in zones) z.id: z.name};
    final explored = sessions.expand((ids) => ids).toSet();

    final progressions = streetsMap.entries.map((entry) {
      final id = entry.key;
      final totalSet = entry.value;
      return QuartierProgression(
        id: id,
        name: nameMap[id] ?? id,
        totalStreets: totalSet.length,
        exploredStreets: totalSet.intersection(explored).length,
      );
    }).toList()
      ..sort((a, b) => b.completionPercent.compareTo(a.completionPercent));

    return progressions;
  });
});
