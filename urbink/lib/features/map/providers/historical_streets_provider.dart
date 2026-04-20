import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Géométries des rues explorées historiquement depuis Firestore.
///
/// Source : `/users/{uid}/streets/{streetId}` → champ `points` (`List&lt;GeoPoint&gt;`).
/// Retourne une map vide si non authentifié.
/// Se met à jour automatiquement via `onSnapshot` dès qu'une rue est sauvegardée.
final historicalStreetsProvider = StreamProvider<Map<String, List<LatLng>>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(<String, List<LatLng>>{});

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('streets')
      .snapshots()
      .map(
        (snapshot) => {
          for (final doc in snapshot.docs)
            doc.id: (doc.data()['points'] as List? ?? [])
                .cast<GeoPoint>()
                .map((gp) => LatLng(gp.latitude, gp.longitude))
                .toList(),
        },
      );
});
