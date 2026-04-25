import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbink/features/profile/providers/week_sessions_provider.dart';
import 'package:urbink/features/sessions/models/session.dart';
import 'package:urbink/features/sessions/providers/session_lifecycle_provider.dart';

/// Nombre de sessions chargées par page.
const int kSessionsPageSize = 20;

/// État de la liste paginée exposé à l'UI.
class SessionsPageState {
  const SessionsPageState({
    required this.sessions,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Session> sessions;

  /// `true` si d'autres sessions sont disponibles côté serveur.
  final bool hasMore;

  /// `true` pendant un chargement de page supplémentaire.
  final bool isLoadingMore;

  SessionsPageState copyWith({
    List<Session>? sessions,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      SessionsPageState(
        sessions: sessions ?? this.sessions,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// Résultat d'un fetch de page.
/// [nextCursor] est opaque (`Object?`) pour rester agnostique de Firestore en test.
typedef SessionsFetchResult = ({List<Session> sessions, Object? nextCursor});

/// Signature du fetcher injectable.
typedef SessionsPageFetcher = Future<SessionsFetchResult> Function(
  String uid, {
  required DateTime? selectedDay,
  required Object? cursor,
});

/// Fetcher production — wraps Firestore.
/// Surchargeable en test via `sessionsPageFetcherProvider.overrideWith(...)`.
final sessionsPageFetcherProvider = Provider<SessionsPageFetcher>((ref) {
  return (uid, {required selectedDay, required cursor}) async {
    Query<Map<String, dynamic>> query;

    if (selectedDay != null) {
      // Requête bornée sur le jour → pas de pagination nécessaire.
      final dayEnd = selectedDay.add(const Duration(days: 1));
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .where('sessionStart',
              isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDay))
          .where('sessionStart', isLessThan: Timestamp.fromDate(dayEnd))
          .orderBy('sessionStart', descending: true)
          .limit(100);
      final snap = await query.get();
      return (
        sessions: snap.docs
            .map((d) => Session.fromFirestore(d.id, uid, d.data()))
            .toList(),
        nextCursor: null,
      );
    } else {
      query = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .orderBy('sessionStart', descending: true);
      if (cursor != null) {
        query = query.startAfterDocument(
            cursor as DocumentSnapshot<Map<String, dynamic>>);
      }
      query = query.limit(kSessionsPageSize);
      final snap = await query.get();
      final docs = snap.docs;
      return (
        sessions:
            docs.map((d) => Session.fromFirestore(d.id, uid, d.data())).toList(),
        nextCursor: docs.isNotEmpty ? docs.last : null,
      );
    }
  };
});

/// Notifier paginé des sessions de l'utilisateur.
///
/// - Chargement initial : première page au `build()`.
/// - Appel à [loadMore] : page suivante, sessions ajoutées en fin de liste.
/// - Changement de [selectedHistogramDayProvider] ou d'uid : reset automatique
///   (Riverpod appelle `build()` à nouveau).
/// - `.autoDispose` : semaine et filtre remis à zéro à la ré-entrée sur l'onglet.
class SessionsListNotifier
    extends AutoDisposeAsyncNotifier<SessionsPageState> {
  Object? _cursor;
  bool _isLoadingMore = false;

  // Compteur de génération pour ignorer les résultats périmés si build() est
  // relancé pendant qu'un loadMore() est en cours.
  int _gen = 0;

  @override
  Future<SessionsPageState> build() async {
    _cursor = null;
    _isLoadingMore = false;
    final gen = ++_gen;

    final uid = ref.watch(currentUidProvider);
    final selectedDay = ref.watch(selectedHistogramDayProvider);

    if (uid == null) {
      return const SessionsPageState(sessions: [], hasMore: false);
    }

    final fetcher = ref.read(sessionsPageFetcherProvider);
    final result = await fetcher(uid, selectedDay: selectedDay, cursor: null);

    if (gen != _gen) {
      return state.valueOrNull ??
          const SessionsPageState(sessions: [], hasMore: false);
    }

    _cursor = result.nextCursor;
    final hasMore =
        selectedDay == null && result.sessions.length == kSessionsPageSize;
    return SessionsPageState(sessions: result.sessions, hasMore: hasMore);
  }

  /// Charge la page suivante et l'appende à la liste courante.
  /// No-op si un chargement est en cours, si `hasMore == false`, ou en mode filtre jour.
  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final gen = _gen;
    _isLoadingMore = true;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final fetcher = ref.read(sessionsPageFetcherProvider);
      final result = await fetcher(uid, selectedDay: null, cursor: _cursor);

      if (gen != _gen) return;

      _cursor = result.nextCursor;
      state = AsyncData(
        SessionsPageState(
          sessions: [...current.sessions, ...result.sessions],
          hasMore: result.sessions.length == kSessionsPageSize,
        ),
      );
    } catch (_) {
      if (gen == _gen) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      }
    } finally {
      _isLoadingMore = false;
    }
  }
}

final sessionsByDayProvider = AsyncNotifierProvider.autoDispose<
    SessionsListNotifier, SessionsPageState>(
  SessionsListNotifier.new,
);
