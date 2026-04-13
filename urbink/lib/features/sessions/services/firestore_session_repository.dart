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
    // Première écriture — inclut createdAt (serverTimestamp) pour dater la création.
    await _firestore
        .collection('users')
        .doc(session.userId)
        .collection('sessions')
        .doc(session.sessionId)
        .set(session.toFirestoreCreate());
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
