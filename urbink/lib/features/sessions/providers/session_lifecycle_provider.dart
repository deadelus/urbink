import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/session_metrics.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_db_provider.dart';
import 'package:urbink/features/sessions/providers/transport_mode_provider.dart';
import 'package:urbink/features/sessions/services/firestore_session_repository.dart';
import 'package:urbink/features/sessions/services/session_repository.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Provider du repository Firestore (injectable en test).
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return FirestoreSessionRepository();
});

/// Stream de changements de connectivité — surchargeable en test.
final connectivityChangesProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Gère le cycle de vie complet d'une session circuit libre :
/// démarrage → persistence sqflite → sauvegarde Firestore → crash recovery.
///
/// State : [Session?] — null si aucune session active.
class SessionLifecycleNotifier extends Notifier<Session?> {
  var _disposed = false;

  @override
  Session? build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Écoute sessionStateProvider : idle→active → démarrer la session
    // Guard : si state != null, une session est déjà active (crash recovery) → skip
    ref.listen(sessionStateProvider, (prev, next) {
      if (prev != SessionState.active && next == SessionState.active && state == null) {
        final mode = ref.read(transportModeProvider);
        _startSession(mode);
      }
    });

    // Écoute connectivité : re-sync les sessions non-synced au retour réseau
    ref.listen(connectivityChangesProvider, (_, next) {
      next.whenData((results) {
        final hasNetwork = results.any((r) => r != ConnectivityResult.none);
        if (hasNetwork) _syncPending();
      });
    });

    return null;
  }

  // ---------------------------------------------------------------------------
  // Démarrage de session
  // ---------------------------------------------------------------------------

  Future<void> _startSession(TransportMode mode) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final sessionId = _uuid.v4();
    final session = Session(
      sessionId: sessionId,
      userId: uid,
      sessionStart: DateTime.now(),
      mode: mode,
      streetIds: const [],
      distanceMeters: 0.0,
    );

    // Persistance locale immédiate (NFR6)
    final cache = ref.read(sessionLocalCacheProvider);
    await cache.insertSession(session);
    if (_disposed) return;

    state = session;

    // Tentative Firestore non-bloquante
    _saveToFirestore(session);
  }

  // ---------------------------------------------------------------------------
  // Arrêt de session + sauvegarde
  // ---------------------------------------------------------------------------

  /// Finalise et sauvegarde la session. Appelé depuis le widget après
  /// confirmation du Dialog "Arrêter la session ?".
  ///
  /// Retourne la [Session] complète pour l'écran récapitulatif.
  Future<Session?> stopAndSave(SessionMetrics metrics) async {
    final current = state;
    if (current == null) return null;

    final mode = ref.read(transportModeProvider);
    final completed = current.copyWith(
      sessionEnd: DateTime.now(),
      mode: mode,
      streetIds: metrics.exploredStreetIds.toList(),
      distanceMeters: metrics.distanceMeters,
    );

    // Mise à jour sqflite
    final cache = ref.read(sessionLocalCacheProvider);
    await cache.updateSession(completed);
    if (_disposed) return completed;

    state = null;

    // Tentative Firestore (avec marquage synced si succès)
    await _saveToFirestoreAndMark(completed);

    return completed;
  }

  // ---------------------------------------------------------------------------
  // Crash recovery
  // ---------------------------------------------------------------------------

  /// Reprend une session interrompue (crash recovery).
  /// Restaure l'état session côté UI.
  Future<void> resumeFromCrash(Session session) async {
    state = session;
    ref.read(sessionStateProvider.notifier).state = SessionState.active;
  }

  /// Annule une session interrompue sans la sauvegarder.
  Future<void> cancelInterrupted(String sessionId) async {
    final cache = ref.read(sessionLocalCacheProvider);
    await cache.markCancelled(sessionId);
  }

  // ---------------------------------------------------------------------------
  // Helpers privés
  // ---------------------------------------------------------------------------

  Future<void> _saveToFirestore(Session session) async {
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.saveSession(session);
    } catch (e) {
      // Échec silencieux — session déjà dans sqflite, sera re-synced
      debugPrint('SessionLifecycle: Firestore save failed (will retry): $e');
    }
  }

  Future<void> _saveToFirestoreAndMark(Session session) async {
    final cache = ref.read(sessionLocalCacheProvider);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.saveSession(session);
      if (!_disposed) {
        await cache.markSynced(session.sessionId);
      }
    } catch (e) {
      debugPrint('SessionLifecycle: Firestore save failed (queued for retry): $e');
      // session_end déjà dans sqflite, synced=0 → sera re-synced à la reconnexion
    }
  }

  Future<void> _syncPending() async {
    try {
      final cache = ref.read(sessionLocalCacheProvider);
      final unsynced = await cache.getUnsyncedSessions();
      if (unsynced.isEmpty || _disposed) return;

      final repo = ref.read(sessionRepositoryProvider);
      await repo.syncSessions(unsynced);
      if (_disposed) return;

      for (final s in unsynced) {
        await cache.markSynced(s.sessionId);
      }
    } catch (e) {
      debugPrint('SessionLifecycle: sync pending failed: $e');
    }
  }
}

final sessionLifecycleProvider =
    NotifierProvider<SessionLifecycleNotifier, Session?>(
  SessionLifecycleNotifier.new,
);
