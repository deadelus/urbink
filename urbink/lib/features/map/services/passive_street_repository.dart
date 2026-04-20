import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistance Firestore des rues explorées en mode passif.
///
/// Chaque rue est sauvegardée sous `users/{userId}/streets/{streetId}`.
/// Appelé dès qu'une rue est colorée pour la première fois dans la session
/// courante (en mémoire), que ce soit pendant ou hors session enregistrée.
abstract interface class PassiveStreetRepository {
  Future<void> saveStreet(String userId, String streetId);

  /// Ajoute un point GPS à la géométrie persistée d'une rue.
  ///
  /// Utilise arrayUnion pour n'écrire que le delta — idempotent si les
  /// mêmes coordonnées sont soumises deux fois.
  Future<void> appendStreetPoint(String userId, String streetId, double lat, double lng);
}

class FirestorePassiveStreetRepository implements PassiveStreetRepository {
  FirestorePassiveStreetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _streetRef(String userId, String streetId) =>
      _firestore.collection('users').doc(userId).collection('streets').doc(streetId);

  @override
  Future<void> saveStreet(String userId, String streetId) async {
    await _streetRef(userId, streetId).set(
      {'lastExploredAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> appendStreetPoint(String userId, String streetId, double lat, double lng) async {
    await _streetRef(userId, streetId).set(
      {
        'lastExploredAt': FieldValue.serverTimestamp(),
        'points': FieldValue.arrayUnion([GeoPoint(lat, lng)]),
      },
      SetOptions(merge: true),
    );
  }
}

final passiveStreetRepositoryProvider = Provider<PassiveStreetRepository>(
  (ref) => FirestorePassiveStreetRepository(),
);
