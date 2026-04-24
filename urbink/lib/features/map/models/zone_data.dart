import 'package:latlong2/latlong.dart';

/// Représente une zone géographique (arrondissement ou quartier) avec son
/// polygone, son centroïde et son libellé pour l'affichage sur la carte.
class ZoneData {
  final String id;
  final String name;
  final LatLng centroid;
  final List<LatLng> polygon;

  const ZoneData({
    required this.id,
    required this.name,
    required this.centroid,
    required this.polygon,
  });

  static ZoneData fromJson(Map<String, dynamic> json) {
    final c = json['center'] as List<dynamic>;
    final pts = json['polygon'] as List<dynamic>;
    return ZoneData(
      id: json['id'] as String,
      name: json['name'] as String,
      centroid: LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble()),
      polygon: pts.map((p) {
        final pt = p as List<dynamic>;
        return LatLng((pt[0] as num).toDouble(), (pt[1] as num).toDouble());
      }).toList(),
    );
  }
}
