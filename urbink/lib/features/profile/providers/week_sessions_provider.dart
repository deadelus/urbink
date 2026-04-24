import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Retourne le lundi de la semaine courante à minuit.
DateTime weekStart(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return today.subtract(Duration(days: today.weekday - 1));
}

/// Date courante injectable — surchargeable en test pour des dates déterministes.
///
/// Partagé par [weekSessionsProvider] et [WeekHistogram] pour garantir
/// que les clés `dayStreets` et les barres utilisent exactement le même `weekStart`.
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

/// Stream brut injectable des sessions pour la semaine donnée.
///
/// Paramètre : `(uid, weekStart)` — borne inférieure = lundi à minuit,
/// borne supérieure = lundi suivant à minuit (7 jours après).
/// Exposé comme `Provider.family` pour être surchargé en test sans Firebase.
final weekSessionsRawStreamProvider =
    Provider.family<Stream<List<Session>>, (String uid, DateTime weekStart)>(
  (ref, params) {
    final (uid, start) = params;
    final end = start.add(const Duration(days: 7));
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .where('sessionStart', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('sessionStart', isLessThan: Timestamp.fromDate(end))
        .orderBy('sessionStart')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Session.fromFirestore(d.id, uid, d.data()))
              .toList(),
        );
  },
);

/// Nombre de rues uniques explorées par jour pour la semaine courante (L→D).
///
/// Clés : minuit du jour (DateTime local).
/// Valeurs : nombre de streetIds uniques explorés ce jour.
/// Retourne une Map vide si l'utilisateur n'est pas authentifié.
/// `.autoDispose` : le provider est recalculé quand l'onglet est réouvert,
/// ce qui garantit un `weekStart` frais après un changement de semaine.
final weekSessionsProvider = StreamProvider.autoDispose<Map<DateTime, int>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value({});

  final now = ref.watch(nowProvider);
  final start = weekStart(now);

  return ref.watch(weekSessionsRawStreamProvider((uid, start))).map((sessions) {
    final dayStreets = <DateTime, Set<String>>{};
    for (final s in sessions) {
      if (s.streetIds.isEmpty) continue;
      final day = DateTime(
        s.sessionStart.year,
        s.sessionStart.month,
        s.sessionStart.day,
      );
      dayStreets.putIfAbsent(day, () => {}).addAll(s.streetIds);
    }
    return dayStreets.map((day, streets) => MapEntry(day, streets.length));
  });
});

/// Jour sélectionné dans le `WeekHistogram` — null = toutes les sorties.
///
/// Mis à jour par tap sur une barre. Si l'utilisateur re-tape le même jour,
/// la sélection est annulée (toggle comportement).
final selectedHistogramDayProvider = StateProvider<DateTime?>((ref) => null);
