import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbink/features/parcours/data/parcours_model.dart';

class ParcoursRepository {
  const ParcoursRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('parcours');

  Future<String> create({
    required String uid,
    required Parcours parcours,
  }) async {
    await _collection(uid).doc(parcours.id).set(parcours.toFirestore());
    return parcours.id;
  }

  Stream<List<Parcours>> streamByUser(String uid) => _collection(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => Parcours.fromFirestore(
              d as DocumentSnapshot<Map<String, dynamic>>))
          .toList());

  Future<void> delete({required String uid, required String parcoursId}) =>
      _collection(uid).doc(parcoursId).delete();
}
