import 'dart:math' show cos, pi;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:urbink/features/map/models/monument.dart';
import 'package:urbink/features/map/providers/monuments_provider.dart';
import 'package:urbink/features/sessions/providers/gps_tracking_provider.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';

/// Rayon de détection de proximité monument (en mètres).
const double kMonumentProximityRadiusMeters = 100.0;

/// Émet chaque monument dès que la position GPS active passe à ≤ 100m.
///
/// Actif uniquement quand la session est [SessionState.active], conforme à AC1.
/// Chaque monument peut être émis plusieurs fois si l'utilisateur entre et sort
/// de la zone — la déduplication est gérée par [monumentBadgeIdsProvider].
final monumentProximityStreamProvider =
    StreamProvider.autoDispose<Monument>((ref) async* {
  final sessionState = ref.watch(sessionStateProvider);
  if (sessionState != SessionState.active) return;

  final monuments = ref.watch(monumentsProvider).valueOrNull;
  if (monuments == null || monuments.isEmpty) return;

  final gpsService = ref.watch(gpsTrackingServiceProvider);
  await for (final position in gpsService.positionStream()) {
    // Bounding box pre-filter : élimine ~99 % des monuments avant le calcul Vincenty.
    const deltaLat = kMonumentProximityRadiusMeters / 111000.0;
    final deltaLon = kMonumentProximityRadiusMeters /
        (111000.0 * cos(position.latitude * pi / 180.0));

    final candidates = monuments.where((m) =>
        (m.position.latitude - position.latitude).abs() <= deltaLat &&
        (m.position.longitude - position.longitude).abs() <= deltaLon);

    for (final monument in candidates) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        monument.position.latitude,
        monument.position.longitude,
      );
      if (distance <= kMonumentProximityRadiusMeters) {
        yield monument;
      }
    }
  }
});
