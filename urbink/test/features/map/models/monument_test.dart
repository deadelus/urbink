import 'package:flutter_test/flutter_test.dart';
import 'package:urbink/features/map/models/monument.dart';

Map<String, dynamic> _feature({
  String id = 'PA00000001',
  String name = 'Tour Eiffel',
  String category = 'Palais & Monuments emblématiques',
  String categoryIcon = '🏛️',
  double lng = 2.2945,
  double lat = 48.8584,
}) =>
    {
      'type': 'Feature',
      'id': id,
      'geometry': {
        'type': 'Point',
        'coordinates': [lng, lat],
      },
      'properties': {
        'id': id,
        'name': name,
        'category': category,
        'category_icon': categoryIcon,
      },
    };

void main() {
  group('Monument.fromGeoJsonFeature', () {
    test('parse les champs de base correctement', () {
      final m = Monument.fromGeoJsonFeature(_feature());
      expect(m.id, 'PA00000001');
      expect(m.name, 'Tour Eiffel');
      expect(m.category, 'Palais & Monuments emblématiques');
      expect(m.categoryIcon, '🏛️');
    });

    test('coordonnées GeoJSON [lng, lat] mappées en LatLng(lat, lng)', () {
      final m = Monument.fromGeoJsonFeature(_feature(lng: 2.2945, lat: 48.8584));
      expect(m.position.latitude, closeTo(48.8584, 0.0001));
      expect(m.position.longitude, closeTo(2.2945, 0.0001));
    });

    test('category_icon absent → icône par défaut 📍', () {
      final feature = _feature();
      (feature['properties'] as Map<String, dynamic>).remove('category_icon');
      final m = Monument.fromGeoJsonFeature(feature);
      expect(m.categoryIcon, '📍');
    });
  });
}
