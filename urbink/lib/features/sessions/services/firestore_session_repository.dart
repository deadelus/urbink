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
    await _firestore
        .collection('users')
        .doc(session.userId)
        .collection('sessions')
        .doc(session.sessionId)
        .set(session.toFirestore());
  }

  @override
  Future<void> syncSessions(List<Session> sessions) async {
    if (sessions.isEmpty) return;

    final batch = _firestore.batch();
    for (final session in sessions) {
      final ref = _firestore
          .collection('users')
          .doc(session.userId)
          .collection('sessions')
          .doc(session.sessionId);
      batch.set(ref, session.toFirestore());
    }
    await batch.commit();
  }
}
