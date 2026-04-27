import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/gamification/models/quartier_badge.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Firestore instance injectable en tests.
final _firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Stream de badges quartier débloqués par l'utilisateur courant.
///
/// Retourne une liste vide si uid null ou si la collection est vide.
/// Documents filtrés : uniquement ceux dont l'id commence par "quartier_".
final quartierBadgesStreamProvider =
    StreamProvider<List<QuartierBadge>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);

  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('users')
      .doc(uid)
      .collection('badges')
      .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'quartier_')
      .where(FieldPath.documentId, isLessThan: 'quartier`')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) =>
              QuartierBadge.fromFirestore(
                  d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());
});

/// Ensemble des quartierId déjà badgés — pour la détection client-side.
final quartierBadgeIdsProvider = Provider<Set<String>>((ref) {
  return ref
      .watch(quartierBadgesStreamProvider)
      .valueOrNull
      ?.map((b) => b.quartierId)
      .toSet() ?? const {};
});

/// Écrit le badge quartier dans Firestore.
/// Idempotent — set() écrase silencieusement si le doc existe déjà.
Future<void> writeQuartierBadge({
  required FirebaseFirestore firestore,
  required String uid,
  required QuartierBadge badge,
}) {
  return firestore
      .collection('users')
      .doc(uid)
      .collection('badges')
      .doc(badge.id)
      .set(badge.toFirestore());
}
