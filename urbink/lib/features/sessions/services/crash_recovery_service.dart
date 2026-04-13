import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/services/session_local_cache.dart';

/// Vérifie au lancement si une session a été interrompue brutalement.
///
/// Une session interrompue = enregistrement sqflite sans `session_end` et
/// non-synchronisé (`synced = 0`).
class CrashRecoveryService {
  final SessionLocalCache _cache;

  CrashRecoveryService(this._cache);

  /// Retourne la session interrompue de [userId] si elle existe, `null` sinon.
  Future<Session?> checkForInterruptedSession(String userId) async {
    return _cache.getInterruptedSession(userId);
  }
}
