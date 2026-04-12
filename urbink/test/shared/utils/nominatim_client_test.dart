import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:urbink/shared/utils/nominatim_client.dart';

void main() {
  group('NominatimClient.reverseGeocode', () {
    test('retourne un NominatimResult valide pour une réponse 200 correcte',
        () async {
      final client = NominatimClient(
        httpClient: MockClient((_) async => http.Response(
              jsonEncode({
                'osm_type': 'way',
                'osm_id': 123456789,
                'display_name': 'Rue de Rivoli, Paris',
              }),
              200,
            )),
      );

      final result =
          await client.reverseGeocode(lat: 48.8566, lon: 2.3522);

      expect(result, isNotNull);
      expect(result!.streetId, 'way:123456789');
      expect(result.displayName, 'Rue de Rivoli, Paris');
    });

    test('retourne null si Nominatim retourne une erreur JSON', () async {
      final client = NominatimClient(
        httpClient: MockClient((_) async => http.Response(
              jsonEncode({'error': 'Unable to geocode'}),
              200,
            )),
      );

      final result =
          await client.reverseGeocode(lat: 0.0, lon: 0.0);

      expect(result, isNull);
    });

    test('retourne null après 3 tentatives sur erreur HTTP 500', () async {
      var callCount = 0;
      final client = NominatimClient(
        httpClient: MockClient((_) async {
          callCount++;
          return http.Response('Internal Server Error', 500);
        }),
        // Bypass du backoff réel (1s + 2s) pour ne pas ralentir la CI.
        retryDelays: [Duration.zero, Duration.zero, Duration.zero],
      );

      final result =
          await client.reverseGeocode(lat: 48.8566, lon: 2.3522);

      expect(result, isNull);
      expect(callCount, 3);
    });

    test('retourne null si osm_type ou osm_id absent', () async {
      final client = NominatimClient(
        httpClient: MockClient((_) async => http.Response(
              jsonEncode({'display_name': 'Paris'}),
              200,
            )),
      );

      final result =
          await client.reverseGeocode(lat: 48.8566, lon: 2.3522);

      expect(result, isNull);
    });
  });
}
