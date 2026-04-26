import 'package:latlong2/latlong.dart';

class Monument {
  final String id;
  final String name;
  final String category;
  final String categoryIcon;
  final String subtype;
  final LatLng position;

  const Monument({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryIcon,
    required this.subtype,
    required this.position,
  });

  static Monument fromGeoJsonFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final coords = (feature['geometry'] as Map<String, dynamic>)['coordinates'] as List<dynamic>;
    return Monument(
      id: props['id'] as String,
      name: props['name'] as String,
      category: props['category'] as String,
      categoryIcon: props['category_icon'] as String? ?? '📍',
      subtype: props['subtype'] as String? ?? '',
      // GeoJSON: [lng, lat]
      position: LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble()),
    );
  }
}
