import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/core/firebase/local_anon_uid.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/models/session_metrics.dart';
import 'package:urbink/features/sessions/models/transport_mode.dart';
import 'package:urbink/features/sessions/providers/session_db_provider.dart';
import 'package:urbink/features/sessions/services/firestore_session_repository.dart';
import 'package:urbink/features/sessions/services/session_repository.dart';
import 'package:urbink/features/sessions/session_state_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Suit les changements d'état Firebase Auth (connexion anonyme, déconnexion).
/// Privé — sert uniquement à alimenter [currentUidProvider] de façon réactive.
final _firebaseAuthUidProvider = StreamProvider<String?>((ref) =>
    FirebaseAuth.instance.authStateChanges().map((user) => user?.uid));

/// UID effectif de l'utilisateur courant.
///
/// Priorité : Firebase UID (nécessaire pour les règles Firestore) → UUID local
/// persisté (généré au 1er lancement, disponible hors-ligne).
///
/// Se met à jour automatiquement quand Firebase Auth signe l'utilisateur
/// (connexion différée ou retour réseau) : tous les providers qui le regardent
/// se reconstruisent sans redémarrage de l'app.
///
/// Injectable en test via [ProviderContainer.overrides].
final currentUidProvider = Provider<String?>((ref) {
  final firebaseUid = ref.watch(_firebaseAuthUidProvider).valueOrNull;
  return firebaseUid ?? localAnonUid;
});

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
  var _isStarting = false;
  var _isSyncing = false;

  @override
  Session? build() {
    _disposed = false;
    _isStarting = false;
    _isSyncing = false;
    ref.onDispose(() => _disposed = true);

    // Écoute sessionStateProvider : idle→active → démarrer la session
    // Guard : si state != null, une session est déjà active (crash recovery) → skip
    ref.listen(sessionStateProvider, (prev, next) {
      if (prev != SessionState.active && next == SessionState.active && state == null) {
        _startSession(TransportMode.walking);
      }
    });

    // Retour réseau : tente la connexion Firebase si nécessaire, puis sync
    ref.listen(connectivityChangesProvider, (_, next) {
      next.whenData((results) {
        final hasNetwork = results.any((r) => r != ConnectivityResult.none);
        if (hasNetwork) {
          _tryFirebaseSignIn();
          _syncPending();
        }
      });
    });

    return null;
  }

  // ---------------------------------------------------------------------------
  // Démarrage de session
  // ---------------------------------------------------------------------------

  Future<void> _startSession(TransportMode mode) async {
    if (_isStarting) return;
    _isStarting = true;

    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      _isStarting = false;
      return;
    }

    final sessionId = _uuid.v4();
    final session = Session(
      sessionId: sessionId,
      userId: uid,
      sessionStart: DateTime.now(),
      mode: mode,
      streetIds: const [],
      distanceMeters: 0.0,
    );

    final cache = ref.read(sessionLocalCacheProvider);
    await cache.insertSession(session);
    _isStarting = false;
    if (_disposed) return;

    state = session;
    _saveToFirestore(session);
  }

  // ---------------------------------------------------------------------------
  // Arrêt de session + sauvegarde
  // ---------------------------------------------------------------------------

  Future<Session?> stopAndSave(SessionMetrics metrics) async {
    final current = state;
    if (current == null) return null;

    final completed = current.copyWith(
      sessionEnd: DateTime.now(),
      mode: metrics.modeTicks.isEmpty ? current.mode : metrics.dominantMode,
      streetIds: metrics.exploredStreetIds.toList(),
      distanceMeters: metrics.distanceMeters,
    );

    final cache = ref.read(sessionLocalCacheProvider);
    await cache.updateSession(completed);
    if (_disposed) return completed;

    state = null;
    unawaited(_saveToFirestoreAndMark(completed));

    return completed;
  }

  // ---------------------------------------------------------------------------
  // Crash recovery
  // ---------------------------------------------------------------------------

  Future<void> resumeFromCrash(Session session) async {
    state = session;
    ref.read(sessionStateProvider.notifier).state = SessionState.active;
  }

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
      debugPrint('SessionLifecycle: Firestore save failed (will retry): $e');
    }
  }

  Future<void> _saveToFirestoreAndMark(Session session) async {
    final cache = ref.read(sessionLocalCacheProvider);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.saveSession(session);
      if (!_disposed) await cache.markSynced(session.sessionId);
    } catch (e) {
      debugPrint('SessionLifecycle: Firestore save failed (queued for retry): $e');
    }
  }

  Future<void> _syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final uid = ref.read(currentUidProvider);
      if (uid == null) return;

      final cache = ref.read(sessionLocalCacheProvider);
      final unsynced = await cache.getUnsyncedSessions(uid);
      if (unsynced.isEmpty || _disposed) return;

      final repo = ref.read(sessionRepositoryProvider);
      await repo.syncSessions(unsynced);
      if (_disposed) return;

      for (final s in unsynced) {
        await cache.markSynced(s.sessionId);
      }
    } catch (e) {
      debugPrint('SessionLifecycle: sync pending failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Tente une connexion Firebase anonyme si l'utilisateur n'est pas encore
  /// connecté (1er lancement hors-ligne ou émulateur indisponible au démarrage).
  ///
  /// En cas de succès :
  ///   1. Si Firebase UID ≠ localAnonUid → migre les sessions SQLite vers le
  ///      nouveau UID et met à jour [localAnonUid] pour les prochains démarrages.
  ///   2. Re-lance [_syncPending] : [currentUidProvider] vient de changer,
  ///      les sessions peuvent maintenant être envoyées à Firestore.
  Future<void> _tryFirebaseSignIn() async {
    if (FirebaseAuth.instance.currentUser != null) return;
    try {
      final result = await FirebaseAuth.instance.signInAnonymously();
      final firebaseUid = result.user?.uid;
      if (firebaseUid == null || _disposed) return;

      final prevUid = localAnonUid;
      if (firebaseUid != prevUid) {
        final cache = ref.read(sessionLocalCacheProvider);
        await cache.migrateUserId(prevUid, firebaseUid);
        await updateLocalAnonUid(firebaseUid);
      }

      // currentUidProvider vient de mettre à jour via _firebaseAuthUidProvider.
      // On force une sync maintenant que Firestore est accessible.
      _syncPending();
    } catch (e) {
      debugPrint('SessionLifecycle: Firebase sign-in retry failed: $e');
    }
  }
}

final sessionLifecycleProvider =
    NotifierProvider<SessionLifecycleNotifier, Session?>(
  SessionLifecycleNotifier.new,
);
