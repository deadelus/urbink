import 'package:cloud_firestore/cloud_firestore.dart';

class QuartierBadge {
  final String id;
  final String quartierId;
  final String name;
  final String secretLocal;
  final DateTime unlockedAt;

  const QuartierBadge({
    required this.id,
    required this.quartierId,
    required this.name,
    required this.secretLocal,
    required this.unlockedAt,
  });

  factory QuartierBadge.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return QuartierBadge(
      id: doc.id,
      quartierId: data['quartierId'] as String,
      name: data['name'] as String,
      secretLocal: data['secretLocal'] as String,
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'quartierId': quartierId,
        'name': name,
        'secretLocal': secretLocal,
        'unlockedAt': Timestamp.fromDate(unlockedAt),
      };

  static String idFor(String quartierId) => 'quartier_$quartierId';
}
