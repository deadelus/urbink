import 'package:urbink/features/sessions/models/session.dart';

/// Interface de persistance des sessions dans le cloud.
abstract class SessionRepository {
  /// Sauvegarde une session dans Firestore (upsert).
  ///
  /// Appelé à la création (sessionEnd null) et à la fin de session (sessionEnd
  /// non-null). L'implémentation est responsable d'écrire `createdAt` une seule
  /// fois (à la première écriture) et de ne pas l'écraser lors des mises à jour.
  Future<void> saveSession(Session session);

  /// Synchronise une liste de sessions non-synced (depuis sqflite).
  Future<void> syncSessions(List<Session> sessions);
}
