import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/parcours/data/parcours_model.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

// URL de la Cloud Function — injecté via --dart-define=FUNCTIONS_BASE_URL.
// Par défaut : projet Firebase de dev.
const _functionsBaseUrl = String.fromEnvironment(
  'FUNCTIONS_BASE_URL',
  defaultValue: 'https://us-central1-urbink-dev.cloudfunctions.net',
);

/// Résultat d'une génération de parcours automatique.
class GeneratedParcoursResult {
  const GeneratedParcoursResult({
    required this.parcours,
    required this.newStreetsCount,
  });

  final Parcours parcours;
  final int newStreetsCount;
}

/// Appelle la Cloud Function `generateParcours` et retourne un circuit.
///
/// L'ID token Firebase Auth est passé en Authorization header.
/// Injectable en test via [parcoursGenerationServiceProvider].
class ParcoursGenerationService {
  const ParcoursGenerationService({
    required http.Client httpClient,
    required Future<String?> Function() getIdToken,
    String baseUrl = _functionsBaseUrl,
  })  : _client = httpClient,
        _getIdToken = getIdToken,
        _baseUrl = baseUrl;

  final http.Client _client;
  final Future<String?> Function() _getIdToken;
  final String _baseUrl;

  /// Génère un circuit automatique autour de [lat]/[lng] pour [durationMinutes]
  /// minutes avec le mode de transport [mode].
  ///
  /// Lance [ParcoursGenerationException] si le timeout (5s) est dépassé ou si
  /// la Cloud Function renvoie une erreur.
  Future<GeneratedParcoursResult> generate({
    required String uid,
    required double lat,
    required double lng,
    required int durationMinutes,
    required TransportMode mode,
  }) async {
    final token = await _getIdToken();
    if (token == null) {
      throw const ParcoursGenerationException('Utilisateur non authentifié');
    }

    final uri = Uri.parse('$_baseUrl/generateParcours');

    late http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'lat': lat,
              'lng': lng,
              'durationMinutes': durationMinutes,
              'mode': mode.firestoreValue,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw const ParcoursGenerationException(
        "Impossible de générer un parcours pour l'instant, réessaie dans quelques instants",
        isTimeout: true,
      );
    }

    if (response.statusCode != 200) {
      throw ParcoursGenerationException(
        "Impossible de générer un parcours pour l'instant, réessaie dans quelques instants",
        statusCode: response.statusCode,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawPoints = (json['points'] as List<dynamic>? ?? []);
    final points = rawPoints
        .map((p) {
          final point = p as Map<String, dynamic>;
          return LatLng(
            (point['lat'] as num).toDouble(),
            (point['lng'] as num).toDouble(),
          );
        })
        .toList();

    final parcours = Parcours(
      id: 'parcours_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Circuit automatique',
      points: points,
      estimatedDistance: (json['estimatedDistance'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt() ?? 0,
      mode: mode,
      type: ParcoursType.auto,
      createdAt: DateTime.now(),
    );

    return GeneratedParcoursResult(
      parcours: parcours,
      newStreetsCount: (json['newStreetsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Exception levée lors d'une erreur de génération.
class ParcoursGenerationException implements Exception {
  const ParcoursGenerationException(
    this.message, {
    this.isTimeout = false,
    this.statusCode,
  });

  final String message;
  final bool isTimeout;
  final int? statusCode;

  @override
  String toString() => 'ParcoursGenerationException: $message';
}
