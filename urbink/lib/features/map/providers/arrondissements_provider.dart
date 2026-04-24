import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/models/zone_data.dart';

final arrondissementsProvider = FutureProvider<List<ZoneData>>((ref) async {
  final raw =
      await rootBundle.loadString('assets/geo/paris/arrondissements.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => ZoneData.fromJson(e as Map<String, dynamic>))
      .toList();
});
