import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/shared/constants/map_constants.dart';

/// Zoom courant de la carte. Mis à jour via [MapOptions.onMapEvent] dans [MapScreen].
/// Utilisé par [MapZonesOverlay] et [ZonesTogglePill] pour basculer entre
/// arrondissements (≤ 13) et quartiers (≥ 14).
final zonesZoomProvider = StateProvider<double>((ref) => MapConstants.initialZoom);
