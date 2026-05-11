import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';

enum ParcoursType {
  auto,
  custom;

  String get firestoreValue => name;

  static ParcoursType fromFirestoreValue(String value) =>
      value == 'custom' ? ParcoursType.custom : ParcoursType.auto;
}

class Parcours {
  final String id;
  final String name;
  final List<LatLng> points;
  final double estimatedDistance;
  final int estimatedDuration;
  final TransportMode mode;
  final ParcoursType type;
  final DateTime createdAt;

  const Parcours({
    required this.id,
    required this.name,
    required this.points,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.mode,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'points': points
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
        'estimatedDistance': estimatedDistance,
        'estimatedDuration': estimatedDuration,
        'mode': mode.firestoreValue,
        'type': type.firestoreValue,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Parcours.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final rawPoints = (d['points'] as List<dynamic>? ?? []);
    return Parcours(
      id: doc.id,
      name: d['name'] as String? ?? '',
      points: rawPoints
          .map((p) {
            final point = p as Map<String, dynamic>;
            return LatLng(
              (point['lat'] as num).toDouble(),
              (point['lng'] as num).toDouble(),
            );
          })
          .toList(),
      estimatedDistance: (d['estimatedDistance'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: (d['estimatedDuration'] as num?)?.toInt() ?? 0,
      mode: TransportMode.fromFirestoreValue(d['mode'] as String? ?? ''),
      type: ParcoursType.fromFirestoreValue(d['type'] as String? ?? ''),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0),
    );
  }
}
