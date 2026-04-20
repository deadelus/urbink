import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/map/providers/time_filter_provider.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Stream brut injectable des listes de streetIds par session.
///
/// Paramètre : `(uid, from)` — `from` est la borne inférieure de date (null = tout).
/// Exposé comme `Provider.family` pour être surchargé en tests sans Firebase.
final sessionsStreetIdsStreamProvider =
    Provider.family<Stream<List<List<String>>>, (String uid, DateTime? from)>(
  (ref, params) {
    final (uid, from) = params;

    var query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('sessionStart', descending: true);

    if (from != null) {
      query = query.where(
        'sessionStart',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => List<String>.from(
                  doc.data()['streetIds'] as List? ?? [],
                ),
              )
              .toList(),
        );
  },
);

/// Union réactive des streetIds explorés, filtrée par [timeFilterProvider].
///
/// Retourne un Set vide si l'utilisateur n'est pas authentifié.
final aggregationProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(<String>{});

  final from = ref.watch(timeFilterProvider.select((f) => f.from));

  return ref
      .watch(sessionsStreetIdsStreamProvider((uid, from)))
      .map((sessions) => sessions.expand((ids) => ids).toSet());
});
