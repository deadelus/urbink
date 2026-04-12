import 'package:geolocator/geolocator.dart';
import 'package:urbink/shared/utils/nominatim_client.dart';

/// Service de snap-to-road via Nominatim.
///
/// Pour chaque position GPS reçue, identifie la rue OSM la plus proche
/// et retourne son identifiant (`osm_type:osm_id`).
///
/// En cas d'erreur réseau persistante, retourne `null` et la session
/// continue sans snap to road (ADR-004).
class SnapToRoadService {
  final NominatimClient _nominatimClient;

  SnapToRoadService({NominatimClient? nominatimClient})
      : _nominatimClient = nominatimClient ?? NominatimClient();

  /// Retourne le `streetId` OSM le plus proche de la position donnée.
  ///
  /// Format : `<osm_type>:<osm_id>` (ex: `way:123456789`).
  /// Retourne `null` si le réseau est indisponible ou en cas d'échec persistant.
  Future<String?> snapToRoad(Position position) async {
    final result = await _nominatimClient.reverseGeocode(
      lat: position.latitude,
      lon: position.longitude,
    );
    return result?.streetId;
  }

  void dispose() => _nominatimClient.dispose();
}
