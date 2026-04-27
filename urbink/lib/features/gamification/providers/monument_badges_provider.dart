import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/monument_badge.dart';
import 'package:urbink/features/gamification/providers/quartier_badges_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Stream de badges monument débloqués par l'utilisateur courant.
///
/// Filtre les documents dont l'id commence par "monument_".
/// Retourne une liste vide si uid null ou collection vide.
final monumentBadgesStreamProvider =
    StreamProvider<List<MonumentBadge>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(uid)
      .collection('badges')
      .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'monument_')
      .where(FieldPath.documentId, isLessThan: 'monument`')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => MonumentBadge.fromFirestore(
              d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());
});

/// Ensemble des monumentId déjà badgés — pour la déduplication client-side.
final monumentBadgeIdsProvider = Provider<Set<String>>((ref) {
  return ref
          .watch(monumentBadgesStreamProvider)
          .valueOrNull
          ?.map((b) => b.monumentId)
          .toSet() ??
      const {};
});

/// Écrit un événement de proximité monument dans Firestore.
///
/// Le document déclenche la Cloud Function [on_monument_proximity] qui
/// vérifie l'idempotence, crée le badge et envoie la notification FCM.
Future<void> writeMonumentProximityEvent({
  required FirebaseFirestore firestore,
  required String uid,
  required String monumentId,
  required String monumentName,
  required String monumentEmoji,
}) {
  return firestore
      .collection('users')
      .doc(uid)
      .collection('monument_proximity_events')
      .doc(MonumentBadge.idFor(monumentId))
      .set({
    'monumentId': monumentId,
    'monumentName': monumentName,
    'monumentEmoji': monumentEmoji,
    'detectedAt': FieldValue.serverTimestamp(),
  });
}
