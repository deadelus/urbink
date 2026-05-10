import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/providers/quartier_badges_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Stream des IDs de collections activées comme objectif par l'utilisateur.
///
/// Stocké dans `/users/{uid}/objectifs/{collectionId}` → `{activatedAt: Timestamp}`.
final activeObjectifIdsStreamProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const {});

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(uid)
      .collection('objectifs')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.id).toSet());
});

/// Active un objectif thématique pour l'utilisateur courant.
Future<void> writeObjectifActivation({
  required FirebaseFirestore firestore,
  required String uid,
  required String collectionId,
}) {
  return firestore
      .collection('users')
      .doc(uid)
      .collection('objectifs')
      .doc(collectionId)
      .set({'activatedAt': FieldValue.serverTimestamp()});
}

/// Désactive un objectif thématique (supprime le document).
Future<void> deleteObjectifActivation({
  required FirebaseFirestore firestore,
  required String uid,
  required String collectionId,
}) {
  return firestore
      .collection('users')
      .doc(uid)
      .collection('objectifs')
      .doc(collectionId)
      .delete();
}
