import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistance Firestore des rues explorées en mode passif.
///
/// Chaque rue est sauvegardée sous `users/{userId}/streets/{streetId}`.
/// Appelé dès qu'une rue est colorée pour la première fois dans la session
/// courante (en mémoire), que ce soit pendant ou hors session enregistrée.
abstract interface class PassiveStreetRepository {
  Future<void> saveStreet(String userId, String streetId);
}

class FirestorePassiveStreetRepository implements PassiveStreetRepository {
  FirestorePassiveStreetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveStreet(String userId, String streetId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('streets')
        .doc(streetId)
        .set(
          {'lastExploredAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
  }
}

final passiveStreetRepositoryProvider = Provider<PassiveStreetRepository>(
  (ref) => FirestorePassiveStreetRepository(),
);
