import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/services/session_repository.dart';

/// Implémentation Firestore de [SessionRepository].
///
/// Path : /users/{userId}/sessions/{sessionId}
class FirestoreSessionRepository implements SessionRepository {
  final FirebaseFirestore _firestore;

  FirestoreSessionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveSession(Session session) async {
    final ref = _firestore
        .collection('users')
        .doc(session.userId)
        .collection('sessions')
        .doc(session.sessionId);

    // Transaction : inclut createdAt (serverTimestamp) uniquement à la création.
    // Si le document existe déjà (ex: appelé au stop après un save au démarrage),
    // on merge sans toucher à createdAt.
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (snap.exists) {
        txn.set(ref, session.toFirestore(), SetOptions(merge: true));
      } else {
        txn.set(ref, session.toFirestoreCreate());
      }
    });
  }

  @override
  Future<void> syncSessions(List<Session> sessions) async {
    if (sessions.isEmpty) return;

    // Resync offline — merge: true préserve createdAt déjà écrit sur le doc.
    final batch = _firestore.batch();
    for (final session in sessions) {
      final ref = _firestore
          .collection('users')
          .doc(session.userId)
          .collection('sessions')
          .doc(session.sessionId);
      batch.set(ref, session.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }
}
