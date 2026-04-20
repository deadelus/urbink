import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Stream brut injectable des listes de streetIds par session.
///
/// Chaque élément est la liste des `streetIds` d'un document session.
/// Exposé comme `Provider.family` pour être surchargé en tests sans Firebase.
final sessionsStreetIdsStreamProvider =
    Provider.family<Stream<List<List<String>>>, String>(
  (ref, uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => List<String>.from(
                doc.data()['streetIds'] as List? ?? [],
              ),
            )
            .toList(),
      ),
);

/// Union réactive de tous les streetIds explorés dans les sessions Firestore.
///
/// Source : `/users/{uid}/sessions/` → champ `streetIds` (`List&lt;String&gt;`).
/// Retourne un Set vide si l'utilisateur n'est pas authentifié.
/// Se met à jour automatiquement lorsqu'une nouvelle session est sauvegardée.
final aggregationProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(<String>{});

  return ref
      .watch(sessionsStreetIdsStreamProvider(uid))
      .map((sessions) => sessions.expand((ids) => ids).toSet());
});
