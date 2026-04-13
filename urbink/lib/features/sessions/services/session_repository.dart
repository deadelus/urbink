import 'package:urbink/features/sessions/models/session.dart';

/// Interface de persistance des sessions dans le cloud.
abstract class SessionRepository {
  /// Sauvegarde une session complète (avec sessionEnd) dans Firestore.
  Future<void> saveSession(Session session);

  /// Synchronise une liste de sessions non-synced (depuis sqflite).
  Future<void> syncSessions(List<Session> sessions);
}
