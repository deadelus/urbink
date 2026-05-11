import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:urbink/features/parcours/data/parcours_model.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

void main() {
  group('ParcoursType', () {
    test('firestoreValue → auto/custom', () {
      expect(ParcoursType.auto.firestoreValue, 'auto');
      expect(ParcoursType.custom.firestoreValue, 'custom');
    });

    test('fromFirestoreValue → custom', () {
      expect(ParcoursType.fromFirestoreValue('custom'), ParcoursType.custom);
    });

    test('fromFirestoreValue → auto par défaut', () {
      expect(ParcoursType.fromFirestoreValue('auto'), ParcoursType.auto);
      expect(ParcoursType.fromFirestoreValue('unknown'), ParcoursType.auto);
    });
  });

  group('Parcours.toFirestore', () {
    final parcours = Parcours(
      id: 'p1',
      name: 'Tour du Marais',
      points: [
        const LatLng(48.8566, 2.3522),
        const LatLng(48.8600, 2.3600),
      ],
      estimatedDistance: 1500.0,
      estimatedDuration: 1200,
      mode: TransportMode.walking,
      type: ParcoursType.auto,
      createdAt: DateTime(2026, 5, 11),
    );

    test('contient tous les champs obligatoires', () {
      final data = parcours.toFirestore();
      expect(data['name'], 'Tour du Marais');
      expect(data['estimatedDistance'], 1500.0);
      expect(data['estimatedDuration'], 1200);
      expect(data['mode'], 'walk');
      expect(data['type'], 'auto');
      expect(data.containsKey('createdAt'), isTrue);
      expect(data.containsKey('points'), isTrue);
    });

    test('sérialise les points en {lat, lng}', () {
      final data = parcours.toFirestore();
      final points = data['points'] as List;
      expect(points.length, 2);
      final p0 = points[0] as Map<String, dynamic>;
      expect(p0['lat'], closeTo(48.8566, 0.0001));
      expect(p0['lng'], closeTo(2.3522, 0.0001));
    });

    test('mode cycling → "bike"', () {
      final p = Parcours(
        id: 'p2',
        name: 'Vélo',
        points: [],
        estimatedDistance: 0,
        estimatedDuration: 0,
        mode: TransportMode.cycling,
        type: ParcoursType.custom,
        createdAt: DateTime(2026),
      );
      expect(p.toFirestore()['mode'], 'bike');
    });

    test('mode driving → "car"', () {
      final p = Parcours(
        id: 'p3',
        name: 'Voiture',
        points: [],
        estimatedDistance: 0,
        estimatedDuration: 0,
        mode: TransportMode.driving,
        type: ParcoursType.auto,
        createdAt: DateTime(2026),
      );
      expect(p.toFirestore()['mode'], 'car');
    });
  });
}
