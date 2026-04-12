import 'dart:convert';

import 'package:http/http.dart' as http;

/// Résultat d'un reverse geocoding Nominatim.
class NominatimResult {
  /// Identifiant de la rue au format `<osm_type>:<osm_id>` (ex: `way:123456789`)
  final String streetId;

  /// Nom affiché par Nominatim (pour debug)
  final String displayName;

  const NominatimResult({required this.streetId, required this.displayName});
}

/// Client HTTP pour l'API Nominatim (OpenStreetMap reverse geocoding).
///
/// Respecte le rate limit de 1 req/s via un délai minimum entre les requêtes.
/// Implémente un retry x3 avec backoff exponentiel (ADR-004).
///
/// Usage :
/// ```dart
/// final client = NominatimClient();
/// final result = await client.reverseGeocode(lat: 48.8566, lon: 2.3522);
/// if (result != null) print(result.streetId); // ex: way:123456789
/// ```
class NominatimClient {
  static const _baseUrl = 'https://nominatim.openstreetmap.org';
  static const _minRequestInterval = Duration(milliseconds: 1100);
  static const _maxRetries = 3;

  final http.Client _httpClient;
  DateTime? _lastRequestTime;

  NominatimClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Reverse geocoding : retourne la rue la plus proche des coordonnées données.
  ///
  /// Retourne `null` en cas d'échec persistant après [_maxRetries] tentatives
  /// ou si les coordonnées ne correspondent à aucune rue OSM.
  Future<NominatimResult?> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    await _respectRateLimit();

    Exception? lastError;
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final result = await _doRequest(lat: lat, lon: lon);
        return result;
      } on Exception catch (e) {
        lastError = e;
        if (attempt < _maxRetries - 1) {
          await Future.delayed(Duration(seconds: 1 << attempt)); // 1s, 2s, 4s
        }
      }
    }

    // Échec persistant — fallback silencieux (ADR-004)
    assert(lastError != null);
    return null;
  }

  Future<NominatimResult?> _doRequest({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
      'lat': lat.toStringAsFixed(7),
      'lon': lon.toStringAsFixed(7),
      'format': 'json',
      'zoom': '17', // niveau rue
      'addressdetails': '0',
    });

    final response = await _httpClient.get(
      uri,
      headers: const {'User-Agent': 'Urbink/1.0 (contact@urbink.app)'},
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Nominatim retourne {"error": "..."} si aucun résultat trouvé
    if (json.containsKey('error')) return null;

    final osmType = json['osm_type'] as String?;
    final osmId = json['osm_id'];
    final displayName = json['display_name'] as String? ?? '';

    if (osmType == null || osmId == null) return null;

    return NominatimResult(
      streetId: '$osmType:$osmId',
      displayName: displayName,
    );
  }

  Future<void> _respectRateLimit() async {
    final last = _lastRequestTime;
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  void dispose() => _httpClient.close();
}
