import 'package:latlong2/latlong.dart';

/// État du composant MapStreetOverlay.
///
/// Maintient la liste des rues explorées (streetId → points GPS)
/// et l'identifiant de la rue actuellement en cours d'exploration.
class MapStreetOverlayState {
  /// Rues explorées : streetId OSM → liste de points GPS ordonnés.
  ///
  /// Format streetId : `<osm_type>:<osm_id>` (ex: `way:123456789`).
  final Map<String, List<LatLng>> exploredStreets;

  /// Rue actuellement en cours d'exploration (état `recording`).
  ///
  /// `null` quand aucune session active ou entre deux positions GPS.
  final String? currentStreetId;

  const MapStreetOverlayState({
    this.exploredStreets = const {},
    this.currentStreetId,
  });

  bool get isEmpty => exploredStreets.isEmpty;

  MapStreetOverlayState copyWith({
    Map<String, List<LatLng>>? exploredStreets,
    String? currentStreetId,
    bool clearCurrentStreetId = false,
  }) {
    return MapStreetOverlayState(
      exploredStreets: exploredStreets ?? this.exploredStreets,
      currentStreetId: clearCurrentStreetId
          ? null
          : (currentStreetId ?? this.currentStreetId),
    );
  }
}
