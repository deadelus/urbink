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

  /// Vrai si ce service a créé le client lui-même — dans ce cas il en est
  /// propriétaire et doit le fermer dans [dispose].
  /// Faux si le client a été injecté (ex: via Riverpod) : c'est alors le
  /// fournisseur du client qui gère son cycle de vie.
  final bool _ownsClient;

  SnapToRoadService({NominatimClient? nominatimClient})
      : _nominatimClient = nominatimClient ?? NominatimClient(),
        _ownsClient = nominatimClient == null;

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

  void dispose() {
    if (_ownsClient) _nominatimClient.dispose();
  }
}
