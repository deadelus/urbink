import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/profile/providers/week_sessions_provider.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Stream brut injectable de toutes les sessions (ordre décroissant).
///
/// Exposé comme `Provider.family` pour être surchargé en test sans Firebase.
final allSessionsRawStreamProvider =
    Provider.family<Stream<List<Session>>, String>(
  // TODO(pagination): remplacer .limit par un curseur quand l'historique dépasse 100 sessions.
  (ref, uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .orderBy('sessionStart', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => Session.fromFirestore(d.id, uid, d.data()))
            .toList(),
      ),
);

/// Liste des sessions de l'utilisateur, filtrée par [selectedHistogramDayProvider].
///
/// - null → toutes les sessions (ordre décroissant)
/// - DateTime → sessions du jour sélectionné uniquement
/// Retourne une liste vide si l'utilisateur n'est pas authentifié.
final sessionsByDayProvider = StreamProvider<List<Session>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);

  final selectedDay = ref.watch(selectedHistogramDayProvider);

  return ref.watch(allSessionsRawStreamProvider(uid)).map((sessions) {
    if (selectedDay == null) return sessions;
    final filterDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    return sessions.where((s) {
      final day = DateTime(
        s.sessionStart.year,
        s.sessionStart.month,
        s.sessionStart.day,
      );
      return day == filterDay;
    }).toList();
  });
});
