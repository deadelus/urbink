import 'package:cloud_firestore/cloud_firestore.dart';

class MonumentBadge {
  final String id;
  final String monumentId;
  final String name;
  final String emoji;
  final DateTime unlockedAt;

  const MonumentBadge({
    required this.id,
    required this.monumentId,
    required this.name,
    required this.emoji,
    required this.unlockedAt,
  });

  factory MonumentBadge.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return MonumentBadge.fromMap(doc.id, doc.data()!);
  }

  factory MonumentBadge.fromMap(String id, Map<String, dynamic> data) {
    return MonumentBadge(
      id: id,
      monumentId: data['monumentId'] as String,
      name: data['name'] as String,
      emoji: data['emoji'] as String? ?? '🏛️',
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'monumentId': monumentId,
        'name': name,
        'emoji': emoji,
        'unlockedAt': Timestamp.fromDate(unlockedAt),
        'type': 'monument',
      };

  static String idFor(String monumentId) => 'monument_$monumentId';
}
